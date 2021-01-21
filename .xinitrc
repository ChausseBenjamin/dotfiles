xwallpaper --zoom ~/.cache/wall.png &
dropbox-cli start &
sxhkd &
remaps &
dunst &
unclutter &
protonmail-bridge --no-window &
xautolock -time 5 -detectsleep -secure -locker locktoggle &
cinnamon-screensaver &
picom -b &
echo "" > $HOME/.local/share/newsboat/queue
echo us > $HOME/.cache/layout
xrdb -load $HOME/.Xresources
flashfocus -n 30 -o 0.75 -v ERROR &
dwmblocks &
newsup &
while true;
do
  exec	dwm
done
# exec icewm
# vim:filetype=sh
