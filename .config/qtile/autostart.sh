#!/usr/bin/env bash 

COLORSCHEME="doom-one"
picom &
/usr/bin/emacs --daemon &
killall conky &
sleep 3 && conky -c "$HOME"/.config/conky/qtile/"$COLORSCHEME"-01.conkyrc
nm-applet &
killall volumeicon &
volumeicon &
cbatticon &

### UNCOMMENT ONLY ONE OF THE FOLLOWING THREE OPTIONS! ###
# 1. Uncomment to restore last saved wallpaper
xargs xwallpaper --stretch < ~/.cache/wall &
# 2. Uncomment to set a random wallpaper on login
# find /usr/share/backgrounds/dtos-backgrounds/ -type f | shuf -n 1 | xargs xwallpaper --stretch &
# 3. Uncomment to set wallpaper with nitrogen
# nitrogen --restore &
