#!/bin/zsh

eval $(dircolors -b)

(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
 
# ┌──────────────────┐ 
# │ AUTO_COMPLETIONS │ 
# └──────────────────┘ 

# Do menu-driven completion.
zstyle ':completion:*' menu select
zstyle ':completion:*:*:git:*' user-commands \
  auth:'authenticate current git repository with ssh key'

# formatting and messages
zstyle ':completion:*' verbose yes

# Completers for my own scripts
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

zstyle ':completion:*' list-colors "${LS_COLORS}"

