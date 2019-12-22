#!/usr/bin/env bash

dp=$(xrandr | grep -E -c "^DP1 con") 
hdmi=$(xrandr | grep -E -c "^HDMI2 con")

if [[ $dp == 0 && $hdmi == 0 ]]; then
    monitor=0
elif [[ $dp != 0 ]]; then
    monitor=1
else
    monitor=2
fi

case $monitor in
    0) xrandr --dpi 210 --fb 2560x1440 \
            --output eDP1 --mode 2560x1440 \
            --pos 0x0 --panning 2560x1440+0+0 ;;
    1) xrandr --dpi 210 --fb 5440x1620 \
            --output DP1 --scale 1.5x1.5 --mode 1920x1080 \
            --pos 0x0 --panning 2880x1620+0+0 \
            --output eDP1 --mode 2560x1440 --right-of DP1 \
            --panning 2560x1440+2880+0 ;;
    2) xrandr --dpi 210 --fb 5080x1650 \
            --output HDMI2 --mode 2200x1650 \
            --pos 0x0 --panning 2200x1650+0+0 \
            --output eDP1 --mode 2560x1440 --right-of DP1 \
            --panning 2560x1440+2200+0 ;;
    *) echo "error monitor setting" ;;
esac

