{pkgs, ...}:
# sh
''
  # Managed by Nix Darwin
  auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
  auth       sufficient     pam_tid.so
''
