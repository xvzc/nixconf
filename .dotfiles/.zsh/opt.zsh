
# ┌────────────┐ 
# │ COMMON ENV │ 
# └────────────┘ 
export CLICOLOR=1
export CLICOLOR_FORCE=1

# reduce esc delay 
export KEYTIMEOUT=1

# set default editor to nvim
export EDITOR=nvim
export VISUAL=nvim

zmodload zsh/nearcolor # Enable hex color codes

# ┌─────────┐ 
# │ VI-MODE │ 
# └─────────┘ 
bindkey -a k history-beginning-search-backward
bindkey -a j history-beginning-search-forward

# ┌─────────────────┐ 
# │ GENERAL KEYMAPS │ 
# └─────────────────┘ 
## Remove keymaps
bindkey -r "^S"
bindkey -r "^D"

# ┌─────────┐ 
# │ HISTORY │ 
# └─────────┘ 
HISTFILE="$HOME/.zsh_history" # location of the history file
SAVEHIST=3000
HISTSIZE=3600 # current session's history limit, also following this https://unix.stackexchange.com/a/595475 $HISTSIZE should be at least 20% bigger than $SAVEHIST 

setopt APPENDHISTORY # ensures that each command entered in the current session is appended
setopt SHARE_HISTORY # allows multiple ZSH sessions to share the same command history 
setopt EXTENDED_HISTORY # records the time when each command was executed
setopt INC_APPEND_HISTORY # history file is updated immediately after a command is entered
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# ┌───────────────┐ 
# │ OTHER OPTIONS │ 
# └───────────────┘ 
## directory stack
setopt AUTO_PUSHD
setopt pushdsilent # Omit printing directory stack
setopt pushdminus  # Invert meanings of +N and -N arguments to pushd
## directory stack end
