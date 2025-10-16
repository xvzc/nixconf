{
  lib,
  pkgs,
  ctx,
  ...
}:
let
  customCompletionPath = ".local/share/zsh/site-functions";
in
{
  home.file = {
    "${customCompletionPath}" = {
      source = ./_files/site-functions;
      recursive = true;
    };
  };

  home.packages = [
    pkgs.pure-prompt
  ];

  programs.zsh = {
    enable = true;
    zprof.enable = false;
    enableCompletion = true;

    completionInit = "autoload -Uz compinit && compinit -C";
    history = {
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      ignorePatterns = [ "rm *" ];
      ignoreSpace = true;
      ignoreDups = true;
      share = true;
      save = 4000;
      size = 4800;
    };

    # These variables will be exported in ~/.zshenv
    sessionVariables = {
      KEYTIMEOUT = 1; # Remove ESC delay
    };

    # defaultKeymap = "viins";

    syntaxHighlighting = {
      enable = true;
      styles = {
        path = "none";
        path_prefix = "none";
        alias = "fg=green";
        builtin = "fg=green";
        command = "fg=green";
        reserved-word = "fg=magenta";
        unknown-token = "fg=red";
        single-quoted-argument = "fg=11";
        double-quoted-argument = "fg=11";
        single-hyphen-option = "fg=white";
        double-hyphen-option = "fg=white";
        command-substitution-delimiter = "fg=magenta,bold";
        process-substitution-delimiter = "fg=magenta,bold";
        dollar-double-quoted-argument = "fg=blue,bold";
        back-double-quoted-argument = "fg=blue,bold";
      };
    };

    envExtra = # sh
      ''
        setopt no_global_rcs
        setopt AUTO_PUSHD
        setopt pushdsilent # Omit printing directory stack
        setopt pushdminus  # Invert meanings of +N and -N arguments to pushd
      '';

    shellAliases = lib.genAttrs (builtins.map toString (lib.range 0 9)) (n: "cd -${n} &> /dev/null");

    initContent = lib.mkMerge [
      (lib.mkBefore # sh
        ''
          [[ -n "$ZPROF" ]] && zmodload zsh/zprof
        ''
      )

      (lib.mkOrder 550 # sh
        ''
          fpath+=($HOME/${customCompletionPath})
          fpath+=(${pkgs.pure-prompt})
        ''
      )

      (lib.mkOrder 1000 # sh
        ''
          # ┌─────────┐ 
          # │ VI-MODE │ 
          # └─────────┘ 
          BLOCK='\e[1 q'
          BEAM='\e[5 q'
          function zle-line-init zle-keymap-select {
            if [[ $KEYMAP == vicmd ]] || [[ $1 = 'block' ]]; then
              echo -ne $BLOCK
            elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] ||
                 [[ $KEYMAP = "" ]] || [[ $1 = "beam" ]]; then
              echo -ne $BEAM
            fi
          }

          zle -N zle-keymap-select
          zle -N zle-line-init

          # Edit line in vim with ctrl-e:
          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey -M viins '^E' edit-command-line
          bindkey -M vicmd '^E' edit-command-line

          # Fix backspace behavior in insert mode
          bindkey -M viins "^H" backward-delete-char
          bindkey -M viins "^?" backward-delete-char

          bindkey '^[[Z' reverse-menu-complete # Enable shift-tab
          bindkey "^[[A" history-beginning-search-backward
          bindkey "^[[B" history-beginning-search-forward
          bindkey -a k history-beginning-search-backward
          bindkey -a j history-beginning-search-forward
        ''
      )

      (lib.mkOrder 1000 # sh
        ''
          # ┌────────┐ 
          # │ STYLES │ 
          # └────────┘ 
          # Set LSCOLORS
          eval "$(dircolors -b)"

          # Do menu-driven completion.
          zstyle ':completion:*' menu select

          # Add git auth command
          zstyle ':completion:*:*:git:*' user-commands \
            auth:'authenticate current git repository with ssh key'

          # Formatting and messages
          zstyle ':completion:*' verbose yes

          # Enable fuzzy matching
          zstyle ":completion:*" matcher-list "" \
            "m:{a-z\-}={A-Z\_}" \
            "r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}" \
            "r:|?=** m:{a-z\-}={A-Z\_}"

          zstyle ':completion:*' list-colors "$EZA_COLORS"

          zmodload zsh/nearcolor
          zstyle :prompt:pure:path color 'blue'
          zstyle :prompt:pure:git:dirty color 'red'
          zstyle :prompt:pure:git:branch color 'cyan'
          zstyle :prompt:pure:virtualenv show yes
          zstyle :prompt:pure:prompt:success color '#f5b5f4'
          zstyle :prompt:pure:execution_time color '#fadf32'

          autoload -U promptinit; promptinit
          prompt pure
        ''
      )

      (lib.mkOrder 1000 # sh
        ''
          # ┌──────────────────┐ 
          # │ OPTIONAL SCRIPTS │ 
          # └──────────────────┘ 
          [ -f $HOME/.secrets ] && source "$HOME/.secrets"
          [ -f $HOME/.zmutable ] && source "$HOME/.zmutable"
        ''
      )

      (lib.mkOrder 1500 # sh
        ''
          function timezsh() {
            shell=''${1-$SHELL}
            for i in $(seq 1 100); do time $shell -i -c exit; done
          }
        ''
      )

      (lib.mkOrder 1500 # sh
        ''
          function nfu() {
            nix flake update nvim-xvzc assets --flake $NIXCONF_DIR
          }
        ''
      )

      (lib.mkOrder 9999 # sh
        ''
          # When macOS is updated, it will typically overwrite '/etc/zshrc'.
          # Because of this known issue, we check if nix-darwin environment 
          # variables are properly loaded and source 'nix-daemon.sh' if not.
          # https://nix.dev/guides/troubleshooting#macos-update-breaks-nix-installation
          if [ -z "''${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]; then
            if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
              . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
            fi
          fi
        ''
      )

      (lib.mkOrder 9999 # sh
        ''
          [[ -n "$ZPROF" ]] && zprof
        ''
      )
    ];
  };
}
