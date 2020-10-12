export GOPATH=$HOME/.go
export SCRIPTS=$HOME/.local/bin
export PATH="$PATH:$(du "$HOME/.scripts/" | cut -f2 | tr '\n' ':')"
export PATH=$PATH:/root/.local/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH$( find $HOME/.local/bin/ -type d -printf ":%p" )
export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/bin/nvim
export READER=/usr/bin/zathura
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export QT_QPA_PLATFORMTHEME="qt5ct"
export GRDB="dropbox://default@/git-private"
export TERM=st
export TERMINAL=st
export BIB=$HOME/Dropbox/A/Scholar/All/References
export REFERBIB=$HOME/Dropbox/A/Scholar/All/References/bibliography.refer
export DISTRIB_ID=arch
export DISTRIB_RELEASE=$(uname -r)
# export GOROOT=/usr/bin/go

# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=$(which firefox)

# less/man colors
export LESS=-R
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')" # begin bold
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')" # begin blink
export LESS_TERMCAP_me="$(printf '%b' '[0m')" # reset bold/blink
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')" # begin reverse video
export LESS_TERMCAP_se="$(printf '%b' '[0m')" # reset reverse video
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')" #begin underline
export LESS_TERMCAP_ue="$(printf '%b' '[0m')" # reset underline

# Start Desktop Environment if on the main TTY
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
startx
fi

# gh completion
eval "$(gh completion -s zsh)"

# Generate shortcuts and aliases
shortcutgen
aliasgen
