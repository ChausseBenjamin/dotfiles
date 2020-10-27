xwallpaper --zoom ~/.cache/wall.png &
dropbox-cli start &
/opt/piavpn/bin/pia-daemon &
sxhkd &
remaps &
dunst &
protonmail-bridge --no-window &
xautolock -time 5 -detectsleep -locker slock &
picom -b &
echo "" > $HOME/.local/share/newsboat/queue
echo us > $HOME/.cache/layout
xrdb -load $HOME/.Xresources
flashfocus -n 30 -o 0.75 -v ERROR &
dwmblocks &
sudo /opt/piavpn/bin/pia-daemon &
# exec icewm
exec dwm
# vim:filetype=sh
