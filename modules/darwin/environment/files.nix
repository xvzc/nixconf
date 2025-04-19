{pkgs, ...}: let
  # sharedEnvironmentFiles = import ../../_shared/environment/files.nix {inherit pkgs;};
in {
  etc = {
      "pam.d/sudo_local".text = import ../assets/sudo_local.nix {inherit pkgs;};
    };
}
