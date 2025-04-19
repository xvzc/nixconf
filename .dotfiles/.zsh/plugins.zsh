#!/bin/zsh

# ┌───────────┐ 
# │ ZSH-DEFER │ 
# └───────────┘ 
zi light romkatv/zsh-defer

zi ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zi light starship/starship
export STARSHIP_CONFIG="$HOME/.config/starship/config.toml"

# ┌─────────────┐ 
# │ ZSH-VI-MODE │ 
# └─────────────┘ 
zi ice depth=1
zi light jeffreytse/zsh-vi-mode
ZVM_VI_EDITOR='nvim'
ZVM_LINE_INIT_MODE='i'
ZVM_VI_HIGHLIGHT_BACKGROUND='white'
ZVM_VI_HIGHLIGHT_FOREGROUND='black'

# ┌─────────────────────────┐ 
# │ ZSH-SYNTAX-HIGHLIGHTING │ 
# └─────────────────────────┘ 
zi light zsh-users/zsh-syntax-highlighting

# ┌───────────────────────────┐ 
# │ ZSH-AUTOSWITCH-VIRTUALENV │ 
# └───────────────────────────┘ 
zi wait lucid for MichaelAquilina/zsh-autoswitch-virtualenv

