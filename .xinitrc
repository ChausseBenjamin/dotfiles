$HOME/.dropbox-dist/dropboxd &
$HOME/.screenlayout/office.sh &
dbus-launch --sh-syntax --exit-with-session; pulseaudio --kill; pipewire &
makewall &
sxhkd &
dunst &
unclutter &
picom -b &
echo us > $HOME/.cache/layout
xrdb -load $HOME/.Xresources
flashfocus -n 30 -t 150 -l never -o 0.75 -v ERROR &
dwmblocks &
remaps &
while true; do
  dwm >/dev/null
done
# exec icewm
# vim:filetype=sh
