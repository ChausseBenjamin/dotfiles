xwallpaper --zoom ~/.cache/wall.png &
crond &
crond -f $HOME/.config/scron/crontab &
nm-applet &
blueman-applet &
pnmixer &
dropbox &
sxhkd &
remaps &
dunst &
protonmail-bridge --no-window &
xautolock -time 5 -detectsleep -locker slock &
picom -b &
echo "/tmp/imapsyncicon_$USER" | entr $SCRIPTS/cron/dwmbar &
echo "" > $HOME/.local/share/newsboat/queue
echo us > $HOME/.cache/layout
xrdb -load $HOME/.Xresources
$SCRIPTS/cron/dwmbar &
flashfocus -n 30 -o 0.9 -v ERROR &
exec dwm
# vim:filetype=sh
