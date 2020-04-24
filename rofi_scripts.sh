#!/usr/bin/env sh

script="$(cat /home/liubianshi/useScript/rofi/rofi_index | dmenu -i -fn 'monospace:size=10' -nb '#222222' -nf '#bbbbbb' -sb '#37474F' -sf '#ffffff')"
rofi_config="-columns 1 -width 50 -lines 10 -bw 2 -location 1 -line-margin 10 -bw 2"

case $script in
    buku) cmd="buku_run";;
    calc) cmd="~/useScript/rofi/rofi-calc.sh";;
    emoji) cmd="rofi -show emoji -modi emoji -columns 3 -width 100 -lines 15 -bw 0 -yoffset -2 -location 1";;
    drun) cmd="rofi -show drun -modi drun $rofi_config";;
    window) cmd="rofi -show window -modi window $rofi_config";;
    uni) cmd="~/useScript/rofi/rofi-uni.sh";;
esac

exec $cmd
