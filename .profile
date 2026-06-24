#!/bin/sh
# shellcheck disable=SC2155

# enable certain tools only if on macOS
case "$OSTYPE" in
darwin*)
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ;;
esac

unsetopt PROMPT_SP 2>/dev/null

# Applications
export EDITOR=nvim
export TERMINAL=ghostty
export TERMINAL_PROG=ghostty
export BROWSER=firefox

# Misc
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
export W3M_DIR="$XDG_CONFIG_HOME/w3m"

export DISTRIB_ID=arch
export DISTRIB_RELEASE="$(uname -r)"
export R_PROFILE_USER="$XDG_CONFIG_HOME/R/Rprofile"
export ZDOTDIR="$XDG_DATA_HOME/zsh"
export TEXMFHOME="$XDG_DATA_HOME/texmf"
export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export QT_QPA_PLATFORMTHEME="gtk3"
export MOZ_USE_XINPUT2=1                  # Mozilla smooth scrolling/touchpad
export AWT_TOOLKIT="MToolkit wmname LG3D" # Fix for Java applications in dwm
export _JAVA_AWT_WM_NONREPARENTING=1      # (this too)
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export HISTFILE="$XDG_CACHE_HOME/zsh_history"
export HISTSIZE=1000
export SAVEHIST=10000
export BAT_THEME="ansi"
export ELECTRON_OZONE_PLATFORM_HINT="wayland"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
[ -f "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"

[ -f "$XDG_CACHE_HOME/bw/env" ] && source "$XDG_CACHE_HOME/bw/env"

# Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$(find "$HOME/.local/bin" -type d | paste -sd ":" -)"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$CARGO_HOME/bin"
export PATH="$PATH:$HOME/.opencode/bin"

export WIREMAN_CONFIG_DIR=$XDG_CONFIG_HOME/wireman
export NODE_OPTIONS="--no-deprecation"

# less/man colors
export LESS="R"
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"

# Set ghostty as the default terminal when not connected via SSH
# or xterm when connected via SSH
[ -z "$SSH_CONNECTION" ] && export TERM=ghostty || export TERM=xterm
export GITHUB_TOKEN="$(tokenfetch 6b3e52a3-e584-4a41-bd8c-349e146a3c37)"

# Generate shortcuts and aliases
source $XDG_CONFIG_HOME/shortcutgen/sources
shortcutgen >/dev/null 2>&1
aliasgen >/dev/null 2>&1
[ -f "$XDG_CACHE_HOME/env-shortcuts" ] && source "$XDG_CACHE_HOME/env-shortcuts"

# Ensure XDG_RUNTIME_DIR is set
if test -z "$XDG_RUNTIME_DIR"; then
  export XDG_RUNTIME_DIR="$(mktemp -d /tmp/$(id -u)-runtime-dir.XXX)"
fi
# Required for prontonvpn-cli
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

# Start Desktop Environment if on the main TTY
[ "$(tty)" = "/dev/tty1" ] && ! pidof mango >/dev/null 2>&1 && {
  # river &
  dbus-launch --exit-with-session mango &
	# mango
  # /usr/bin/pipewire &
  # /usr/bin/wireplumber &
  # /usr/bin/pipewire-pulse &
}
export GPG_TTY=$(tty)
gpg-connect-agent /bye 2>/dev/null || gpg-agent --daemon
