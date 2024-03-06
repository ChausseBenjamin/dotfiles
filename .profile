# Path
export SCRIPTS=$HOME/.local/bin
export PATH=$PATH$(find "$SCRIPTS/" -type d -printf ":%p")
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:/root/.local/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/go/bin

# QT & GTK
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export QT_QPA_PLATFORMTHEME="qt5ct"

# Misc
export DISTRIB_ID=arch
export DISTRIB_RELEASE=$(uname -r)
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export R_PROFILE_USER=$HOME/.config/R/Rprofile
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
export TEXMFHOME=$XDG_DATA_HOME/texmf
export TEXSRC=$HOME/.local/src/sherbrooke-tex

# Applications
export EDITOR=$(which nvim)
export READER=/usr/bin/zathura
export TERMINAL=/usr/local/bin/st
export TERM=/usr/local/bin/st
export BROWSER=/usr/bin/firefox

# less/man colors
export LESS=-R
export LESS_TERMCAP_md=$'\e[01;36;74m'  # begin bold
export LESS_TERMCAP_mb=$'\e[01;31;4m'   # begin blinking
export LESS_TERMCAP_us=$'\e[04;32;146m' # begin underline
export LESS_TERMCAP_so=$'\e[30;42;146m' # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'         # end reverse video
export LESS_TERMCAP_me=$'\e[0m'         # end mode
export LESS_TERMCAP_ue=$'\e[0m'         # end underline

# Generate shortcuts and aliases
shortcutgen
aliasgen

# Import shortcut ENV variables
source "$HOME/.cache/env-shortcuts"

# Ensure XDG_RUNTIME_DIR is set
if test -z "$XDG_RUNTIME_DIR"; then
	export XDG_RUNTIME_DIR=$(mktemp -d /tmp/$(id -u)-runtime-dir.XXX)
fi

# Start Desktop Environment if on the main TTY
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	startx
fi
