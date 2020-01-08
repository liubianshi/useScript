#!/usr/bin/env bash
#file="$NUTSTORE/Sync/uni_history"
options='-columns 6 -width 100 -lines 20 -bw 2 -yoffset -2 -location 1'
rofimoji -c --rofi-args="$options"
#temp=$(xclip -o | xargs uni)
#sed -Ei "1i\\$temp" "$file"


