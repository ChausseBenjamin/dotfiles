export GOPATH=$HOME/.go
export SCRIPTS=$HOME/.local/bin
export PATH=$PATH$( find $HOME/.local/bin/ -type d -printf ":%p" )
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:/root/.local/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:/usr/local/go/bin
export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/local/bin/nvim
export READER=/usr/bin/zathura
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export QT_QPA_PLATFORMTHEME="qt5ct"
export GRDB="dropbox://default@/git-private"
export TERMINAL=/usr/local/bin/st
export TERM=/usr/local/bin/st
export BIB=$HOME/Dropbox/A/Scholar/All/References
export REFERBIB=$HOME/Dropbox/A/Scholar/All/References/bibliography.refer
export DISTRIB_ID=arch
export DISTRIB_RELEASE=$(uname -r)
export XDG_CONFIG_HOME=$HOME/.config
export R_PROFILE_USER=$HOME/.config/R/Rprofile
export TODOIST_API_KEY="$(pass Todoist/API)"
# export GOROOT=/usr/bin/go

# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=$(which firefox)

# less/man colors
export LESS=-R
export LESS_TERMCAP_md=$'\e[01;36;74m'  # begin bold
export LESS_TERMCAP_mb=$'\e[01;31;4m'   # begin blinking
export LESS_TERMCAP_us=$'\e[04;32;146m' # begin underline
export LESS_TERMCAP_so=$'\e[30;42;146m' # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'         # end reverse video
export LESS_TERMCAP_me=$'\e[0m'         # end mode
export LESS_TERMCAP_ue=$'\e[0m'         # end underline

# Start Desktop Environment if on the main TTY
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
startx
fi

# gh completion
eval "$(gh completion -s zsh)"

# Generate shortcuts and aliases
shortcutgen
aliasgen
. "$HOME/.cargo/env"
export PATH=$PATH:/home/master/.local/src/Geekbench-6.2.0-Linuxexport PATH=$PATH:/home/master/.local/src/Geekbench-6.2.0-Linuxexport PATH=$PATH:/home/master/.local/src/Geekbench-6.2.0-Linux