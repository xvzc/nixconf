# kime Patches

Local patches on top of the nixpkgs `kime` 3.2.0 package, applied in file-name order
from `../default.nix`. All of them touch `src/frontends/wayland/src/state.rs`
(`kime-wayland`), so each one is made against the result of the previous ones.

Drop a patch once the fix ships in the kime release that nixpkgs packages.

## 01-wayland-skip-redundant-preedit.patch

- Status: local fix, reported upstream as
  [Riey/kime#817](https://github.com/Riey/kime/issues/817). Verified on this machine.
- Path: input-method-v2 (Hyprland).
- Symptom: in Chrome, type Hangul only, select all while the last syllable is still
  being composed, then press Ctrl. The selected text is deleted.
- Cause: on a bare Ctrl/Alt/Super press the engine keeps the composition and returns
  `HAS_PREEDIT`. `process_input_result_v2` then re-sends the unchanged preedit and a
  `commit`. The client already ended the composition when the selection changed, so
  it treats the re-sent preedit as a new one and replaces the selection with it.
- Fix: remember the last preedit sent, skip `set_preedit_string` when it is unchanged,
  send `commit` only when something was sent, and forget the value on deactivate.
- Follow-up fix (local only, not added to #817): the skip must not apply when a commit
  string is sent in the same batch. Every `done` resets the client's preedit, so with
  `ComposeChoseongSsang` off, ㄱ + ㄱ committed the first ㄱ and dropped the second one
  from the screen (the engine still held it until the next non-Hangul key). The preedit
  is now always re-sent alongside a non-empty commit.

## 02-wayland-v1-reset-engine.patch

- Status: copy of the open upstream PR
  [Riey/kime#813](https://github.com/Riey/kime/pull/813), which fixes
  [Riey/kime#812](https://github.com/Riey/kime/issues/812). Only the `state.rs` part
  is included, not the changelog.
- Path: input-method-v1 (KWin). It has no effect on Hyprland, so it is not verified
  here.
- Symptom: click elsewhere while composing, keep typing, and the composed syllable is
  inserted a second time at the new cursor position.
- Cause: the client commits the preedit itself and KWin forwards that as the context
  `reset` event, which kime ignored. The engine kept the syllable and committed it
  again with the next key.
- Fix: on `reset`, call `engine.reset()` under the same `engine_ready` guard as
  `Deactivate`.

## 03-wayland-password-passthrough.patch

- Status: local fix, not reported upstream. Verified in Chrome on this machine: in a
  password field (`content_type(192, 8)`), Super+Space and letter keys reach the
  client untouched. Only covers clients that use text-input; GTK clients that go
  through the kime GTK module (such as Firefox) are not affected by this patch.
- Path: input-method-v2 (Hyprland).
- Symptom: in Chrome on Wayland, Hangul can be toggled and typed in password fields.
  Under XWayland the client disables XIM there, so only Latin input reaches the field.
- Cause: kime ignored the `content_type` event, so it never knew the field was a
  password field.
- Fix: track `content_type` (reset on `activate`, applied on `done`). For purpose
  `password` or `pin`, or hint `sensitive_data` or `hidden_text`, release the keyboard
  grab so keys pass through untouched, and drop any composition on entering the
  field.

## 04-gtk-password-passthrough.patch

- Status: local fix, not reported upstream. Verified in Firefox on this machine.
- Path: GTK3/GTK4 input module (`src/frontends/gtk3/src/immodule.c`, shared by both),
  used by GTK clients through `GTK_IM_MODULE=kime`, such as Firefox.
- Symptom: in Firefox, Hangul is composed in password fields.
- Cause: the module ignored the context's `input-purpose` property.
- Fix: in `filter_keypress`, return `FALSE` for `GTK_INPUT_PURPOSE_PASSWORD` and
  `GTK_INPUT_PURPOSE_PIN`, so GTK handles the key itself. Delayed events that kime
  re-injected itself are still processed first.

## Related

The nixpkgs package also misses the `LD_LIBRARY_PATH` wrapper for `kime-wayland`, so it
panics with `NoWaylandLib`. That is fixed in `../default.nix` with `wrapProgram`, not
with a patch. kime's own Nix expression fixed the same issue in
[Riey/kime#808](https://github.com/Riey/kime/pull/808), but nixpkgs has not picked it
up.
