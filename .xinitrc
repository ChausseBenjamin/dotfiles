$XDG_CONFIG_HOME/startup/$(hostname) &
sxhkd &
dunst &
unclutter &
picom -b &
echo us >$HOME/.cache/layout
xrdb -load $HOME/.Xresources
flashfocus -n 30 -t 150 -l never -o 0.75 -v ERROR &
dwmblocks &
remaps &
while true; do
	#   Start dwm (loop restarts it if it crashes)
	#   dwm >/dev/null
	#   Trying to launch dwm with dbus-launch
	dbus-launch --exit-with-session dwm
done
# vim:filetype=sh
