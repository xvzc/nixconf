{
  ctx,
  lib,
  pkgs,
  config,
  ...
}:
# assert builtins.hasAttr ".zsh" config.home.file;
let
  plugins = {
    pure = pkgs.fetchgit {
      url = "https://github.com/sindresorhus/pure";
      rev = "92b8e9057988566b37ff695e70e2e9bbeb7196c8";
      sha256 = "TbOrnhLHgOvcfsgmL0l3bWY33yLIhG1KSi4ITIPq1+A=";
    };
    zsh-defer = pkgs.fetchgit {
      url = "https://github.com/romkatv/zsh-defer.git";
      rev = "53a26e287fbbe2dcebb3aa1801546c6de32416fa";
      sha256 = "MFlvAnPCknSgkW3RFA8pfxMZZS/JbyF3aMsJj9uHHVU=";
    };

    zsh-syntax-highlighting = pkgs.fetchgit {
      url = "https://github.com/zsh-users/zsh-syntax-highlighting.git";
      rev = "5eb677bb0fa9a3e60f0eff031dc13926e093df92";
      sha256 = "IIcGYa0pXdll/XDPA15zDBkLUuLhTdrqwS9sn06ce0Y=";
    };
  };
in
{
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

  syntaxHighlighting = {
    enable = true;
  };

  defaultKeymap = "viins";

  # These variables will be exported in ~/.zshenv
  sessionVariables = {
    NIXNAME = ctx.machine;
    PIP_REQUIRE_VIRTUALENV = true;
    KEYTIMEOUT = 1; # Remove ESC delay
    EDITOR = "nvim";
    VISUAL = "nvim";
    EZA_COLORS = lib.strings.concatStrings [
      "da=37:di=34:" # Directories
      "gu=97;1:gn=2;3:gR=90;2;3:" # Groups
      "uu=97;1:un=2;3:uR=90;2;3:" # Users
    ];
  };

  envExtra = # sh
    ''
      setopt no_global_rcs
      setopt AUTO_PUSHD
      setopt pushdsilent # Omit printing directory stack
      setopt pushdminus  # Invert meanings of +N and -N arguments to pushd

      export PATH=$PATH:$HOME/.local/bin
      export PATH=$PATH:$HOME/.scripts/git
      export PATH=$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts
      ${lib.optionalString ctx.isDarwin "export PATH=$PATH:/opt/homebrew/bin"}
    '';

  initExtraFirst = # sh
    ''
      [[ -n "$ZPROF" ]] && zmodload zsh/zprof

      DOT_ZSH=$HOME/.zsh

      autoload -Uz ${plugins.zsh-defer}/zsh-defer
    '';

  initExtraBeforeCompInit = # sh
    ''
      fpath+=($DOT_ZSH/_completion)
      fpath+=(${plugins.pure})
    '';

  initExtra = # sh
    ''
      # ┌───────────────────┐ 
      # │ ADDITIONAL CONFIG │ 
      # └───────────────────┘ 
      # Set LSCOLORS
      eval "$(dircolors -b)"

      (( ''${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[path]=none
      ZSH_HIGHLIGHT_STYLES[path_prefix]=none
      ZSH_HIGHLIGHT_STYLES[alias]=fg=green
      ZSH_HIGHLIGHT_STYLES[builtin]=fg=green
      ZSH_HIGHLIGHT_STYLES[command]=fg=green
      ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red
      ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow,bold
      ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow,bold
      ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=cyan,bold
      ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=cyan,bold

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

      # ┌──────────────┐ 
      # │ LOAD PLUGINS │ 
      # └──────────────┘ 
      zsh-defer source ${plugins.zsh-syntax-highlighting}/zsh-syntax-highlighting.plugin.zsh

      # ┌──────────────────┐ 
      # │ OPTIONAL SCRIPTS │ 
      # └──────────────────┘ 
      [ -f $HOME/.secrets ] && zsh-defer source "$HOME/.secrets"
      [ -f $HOME/.zmutable ] && zsh-defer source "$HOME/.zmutable"

      autoload -U promptinit; promptinit
      prompt pure

      [[ -n "$ZPROF" ]] && zprof
    '';

  profileExtra = # sh
    ''
      # ┌───────────┐ 
      # │ FUNCTIONS │ 
      # └───────────┘ 
      function timezsh() {
        shell=''${1-$SHELL}
        for i in $(seq 1 100); do time $shell -i -c exit; done
      }

      function fvi() {
        out=$( \
          fd -L --type f --hidden --relative-path --follow --exclude .git $1 \
            | fzf \
            --preview 'bat --style=numbers --color=always --line-range :500 {}' \
            --query=$1 \
        )

        [[ ! -z $out ]] && nvim $out
      }

      function fcd() {
        out=$( \
          fd -L --type d --hidden --relative-path \
            | fzf \
            --preview='tree {}' \
            --query=$1 \
        )

        [[ ! -z $out ]] && cd $out
      }
    '';

  shellAliases =
    lib.genAttrs (builtins.map toString (lib.range 0 9)) (n: "cd -${n} &> /dev/null")
    // {
      "d" = "dir -v";
      "tas" = "tmux -u attach-session -t";
      "tds" = "tmux detach";
      "tks" = "tmux kill-session -t";
      "tss" = "tmux -u switch -t";
      "tns" = "tmux -u new -c ~ -s";
      "tls" = "tmux ls";
    };
}
