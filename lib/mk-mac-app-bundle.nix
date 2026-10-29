# lib/mk-mac-app-bundle.nix
#
# Wrap a real Mach-O command-line binary in a minimal macOS app bundle and
# ad-hoc sign the result, so per-identifier trust grants (TCC, window-manager
# permissions) can name a stable bundle identifier instead of a store path.
#
# Trust limitation: the signature is ad-hoc (no keys or certificates) with an
# identifier-only designated requirement (`identifier "<id>"`). Anyone can
# produce the same claim for the same identifier, so this establishes a
# stable name, not authenticity or integrity against a malicious actor.
#
# Narrow scope and unsupported inputs: this helper only copies a single thin
# Mach-O executable. It deliberately rejects anything else rather than
# guessing:
# - scripts and makeWrapper-style wrappers (the signature must cover the
#   Mach-O that actually runs, not a launcher that sets up an environment);
# - universal (fat) binaries (per-slice inspection and signing is out of
#   scope; the main candidates are thin);
# - binaries loading libraries via @executable_path, @loader_path or @rpath
#   (a bundle moves the binary, so those paths would no longer resolve);
# - binaries carrying entitlements (ad-hoc re-signing without entitlements
#   silently drops them, so they are refused instead of neutered).
#
# Names and the identifier are restricted to a safe charset at evaluation
# time, which is also what makes interpolating them into the shell script and
# Info.plist below safe. All inspection output is captured fully with checked
# exit statuses before searching (no `producer | grep -q` pipelines), and any
# inspection failure fails the build closed. Signing and signature inspection
# inside the build use the declared rcodesign package only: the host
# codesign is used solely as external post-build validation, never inside
# the derivation, and no private keys, certificates, or keychain access are
# involved anywhere.
{ pkgs }:

{
  package,
  identifier,
  mainProgram ? package.meta.mainProgram or package.pname,
}:

let
  lib = pkgs.lib;

  namePattern = "[A-Za-z0-9][A-Za-z0-9._-]*";
  identifierPattern = "[A-Za-z][A-Za-z0-9.-]*";
  versionPattern = "[A-Za-z0-9][A-Za-z0-9._+~]*";

  appName =
    package.pname
      or (throw "mk-mac-app-bundle: `package` has no `pname`, so the bundle name cannot be derived");
  version = package.version or "0";
in
assert lib.assertMsg (pkgs.stdenv.isDarwin
) "mk-mac-app-bundle: app bundles can only be built on Darwin";
assert lib.assertMsg (lib.isDerivation package)
  "mk-mac-app-bundle: `package` must be a Nix derivation";
assert lib.assertMsg (
  lib.isString mainProgram && builtins.match namePattern mainProgram != null
) "mk-mac-app-bundle: `mainProgram` must match ${namePattern}, got ${builtins.toJSON mainProgram}";
assert lib.assertMsg (
  lib.isString appName && builtins.match namePattern appName != null
) "mk-mac-app-bundle: package `pname` must match ${namePattern}, got ${builtins.toJSON appName}";
assert lib.assertMsg
  (lib.isString identifier && builtins.match identifierPattern identifier != null)
  "mk-mac-app-bundle: `identifier` must match ${identifierPattern}, got ${builtins.toJSON identifier}";
assert lib.assertMsg (lib.isString version && builtins.match versionPattern version != null)
  "mk-mac-app-bundle: package `version` must match ${versionPattern}, got ${builtins.toJSON version}";

pkgs.runCommand "${appName}-${version}-app-bundle"
  {
    pname = appName;
    src = "${package}/bin/${mainProgram}";
    inherit
      appName
      mainProgram
      identifier
      version
      ;
    nativeBuildInputs = [
      pkgs.cctools
      pkgs.rcodesign
      (pkgs.python3.withPackages (ps: [ ps.pyyaml ]))
    ];
    meta = {
      description = "${appName} as a macOS app bundle";
      mainProgram = mainProgram;
    };
  }
  ''
    set -euo pipefail

    # Binary form of: designated => identifier "<identifier>".
    # Adapted from scripts/stabilize.sh in natsukium/nix-mac-app-identity
    # (Apache-2.0): magic(4) length(4) kind(4) opIdent(4) strlen(4) identifier
    # padding. rcodesign only accepts compiled requirements, and compiling
    # here avoids host tools and keychain access during the build.
    emitRequirement() {
      local LC_ALL=C
      local reqId=$1 file=$2 len pad header="" padding="" word n
      len=''${#reqId}
      pad=$(((4 - len % 4) % 4))
      for word in $((0xfade0c00)) $((20 + len + pad)) 1 2 "$len"; do
        header+=$(printf '\\0%03o\\0%03o\\0%03o\\0%03o' \
          $((word >> 24 & 255)) $((word >> 16 & 255)) $((word >> 8 & 255)) $((word & 255)))
      done
      for ((n = 0; n < pad; n++)); do padding+='\0000'; done
      printf '%b%s%b' "$header" "$reqId" "$padding" >"$file"
    }

    if [ ! -f "$src" ]; then
      echo "mk-mac-app-bundle: $src does not exist or is not a regular file" >&2
      exit 1
    fi

    # A wrapper script cannot be the bundle executable: the signature must
    # cover the Mach-O that actually runs.
    prefix=$(head -c 2 "$src" 2>/dev/null) || {
      echo "mk-mac-app-bundle: cannot read $src" >&2
      exit 1
    }
    if [ "$prefix" = '#!' ]; then
      echo "mk-mac-app-bundle: $src is a script; only a real Mach-O executable is supported" >&2
      exit 1
    fi

    # Must be a Mach-O binary at all. (otool exits 0 even for non-object
    # files, so the magic number is checked directly.)
    magic=$(od -An -tx4 -N4 "$src" 2>/dev/null) || {
      echo "mk-mac-app-bundle: cannot read $src" >&2
      exit 1
    }
    magic=''${magic//[[:space:]]/}
    case "$magic" in
      feedfacf|cffaedfe|feedface|cefaedfe) ;;
      cafebabe|bebafeca|cafebabf|bfbafeca)
        echo "mk-mac-app-bundle: $src is a universal (fat) binary, which is not supported" >&2
        exit 1
        ;;
      *)
        echo "mk-mac-app-bundle: $src is not a Mach-O binary" >&2
        exit 1
        ;;
    esac

    # ... and an actual executable, not a dylib or other Mach-O object file.
    machHdr=$(otool -hv "$src" 2>/dev/null) || {
      echo "mk-mac-app-bundle: cannot parse Mach-O headers of $src" >&2
      exit 1
    }
    machHdr=''${machHdr#*$'\n'}
    if [[ ! $machHdr =~ EXECUTE ]]; then
      echo "mk-mac-app-bundle: $src is not a Mach-O executable (expected filetype EXECUTE)" >&2
      exit 1
    fi

    # Moving the binary into a bundle breaks @executable_path, @loader_path
    # and @rpath resolution, so refuse rather than ship a broken binary.
    loadCmds=$(otool -l "$src" 2>/dev/null) || {
      echo "mk-mac-app-bundle: cannot parse load commands of $src" >&2
      exit 1
    }
    if [[ $loadCmds =~ @(executable_path|loader_path|rpath) ]]; then
      echo "mk-mac-app-bundle: $src loads libraries relative to its own location:" >&2
      grep -E '@(executable_path|loader_path|rpath)' <<< "$loadCmds" >&2
      echo "mk-mac-app-bundle: a bundle moves the binary, so those paths would no longer resolve" >&2
      exit 1
    fi

    # Inspect fields, not report text: identifiers and entitlement values can
    # contain strings like "signature: null". Refuse both XML and DER slots.
    if ! rcodesign print-signature-info "$src" > signature.yaml; then
      echo "mk-mac-app-bundle: cannot inspect code signature of $src" >&2
      exit 1
    fi
    python3 - <<'PY'
    import sys
    import yaml

    try:
        with open("signature.yaml") as report_file:
            report = yaml.safe_load(report_file)
        if not isinstance(report, list) or len(report) != 1:
            raise ValueError("expected one thin Mach-O report")
        signature = report[0]["entity"]["mach_o"]["signature"]
        if signature is not None:
            blobs = signature["blobs"]
            if not isinstance(blobs, list) or not blobs or len(blobs) != signature["blob_count"]:
                raise ValueError("invalid signature blob list")
            slots = [blob["slot"] for blob in blobs]
            if not all(isinstance(slot, str) for slot in slots) or len(set(slots)) != len(slots):
                raise ValueError("invalid signature slots")
            if "Entitlements (5)" in slots or "DER Entitlements (7)" in slots:
                sys.exit("mk-mac-app-bundle: input carries entitlements; refusing to silently strip them")
            if "CodeDirectory (0)" not in slots or not isinstance(signature["code_directory"], dict):
                raise ValueError("missing code directory")
    except (yaml.YAMLError, KeyError, TypeError, ValueError) as error:
        sys.exit(f"mk-mac-app-bundle: cannot determine signature state: {error}")
    PY

    app="$out/Applications/$appName.app"
    exe="$app/Contents/MacOS/$mainProgram"
    mkdir -p "$app/Contents/MacOS" "$out/bin"
    cp "$src" "$exe"
    chmod u+w "$exe"

    cat > "$app/Contents/Info.plist" <<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleExecutable</key><string>$mainProgram</string>
      <key>CFBundleIdentifier</key><string>$identifier</string>
      <key>CFBundleName</key><string>$appName</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
      <key>CFBundleShortVersionString</key><string>$version</string>
      <key>CFBundleVersion</key><string>$version</string>
      <key>LSUIElement</key><true/>
    </dict>
    </plist>
    EOF

    printf 'APPL????' > "$app/Contents/PkgInfo"

    # Ad-hoc sign (no keys or certificates) with the compiled identifier-only
    # designated requirement, so trust decisions can name a stable identifier
    # instead of a store-path-bound cdhash. The scoped arguments give the
    # executable inside the bundle the same identifier and requirement.
    emitRequirement "$identifier" requirement.bin
    rcodesign sign \
      --binary-identifier "$identifier" \
      --code-requirements-file requirement.bin \
      --binary-identifier "Contents/MacOS/$mainProgram:$identifier" \
      --code-requirements-file "Contents/MacOS/$mainProgram:$PWD/requirement.bin" \
      "$app"

    # The build fails unless the requirement is exactly the identifier above.
    escId=''${identifier//./\\.}
    reqPat="designated\\([0-9]+\\): [0-9]+: identifier \"$escId\";"
    for target in "$exe" "$app"; do
      targetInfo=$(rcodesign print-signature-info "$target" 2>/dev/null) || {
        echo "mk-mac-app-bundle: cannot read back signature of $target" >&2
        exit 1
      }
      if [[ ! $targetInfo =~ $reqPat ]]; then
        echo "mk-mac-app-bundle: $target lacks the designated requirement identifier \"$identifier\"" >&2
        exit 1
      fi
    done

    ln -s "../Applications/$appName.app/Contents/MacOS/$mainProgram" "$out/bin/$mainProgram"
  ''
