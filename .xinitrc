xwallpaper --zoom ~/.cache/wall.png &
dropbox-cli start &
sxhkd &
remaps &
dunst &
protonmail-bridge --no-window &
xautolock -time 5 -detectsleep -locker slock &
picom -b &
echo "" > $HOME/.local/share/newsboat/queue
echo us > $HOME/.cache/layout
xrdb -load $HOME/.Xresources
dwmblocks &
flashfocus -n 30 -o 0.9 -v ERROR &
exec dwm
# vim:filetype=sh
