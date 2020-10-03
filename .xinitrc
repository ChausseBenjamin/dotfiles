xwallpaper --zoom ~/.cache/wall.png &
crond &
crond -f $HOME/.config/scron/crontab &
nm-applet &
blueman-applet &
pnmixer &
dropbox &
sxhkd &
$SCRIPTS/remaps &
dunst &
protonmail-bridge --no-window &
xautolock -time 5 -detectsleep -locker slock &
picom -b &
flashfocus &
echo "/tmp/imapsyncicon_$USER" | entr $SCRIPTS/cron/dwmbar &
echo "" > $HOME/.local/share/newsboat/queue
echo us > $HOME/.cache/layout
xrdb -load $HOME/.Xresources
$SCRIPTS/cron/dwmbar &
exec dwm
# vim:filetype=sh
