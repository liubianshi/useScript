#!/usr/bin/env bash

dp=$(xrandr | grep -E -c "^DP1 con") 
hdmi=$(xrandr | grep -E -c "^HDMI2 con")
right=0

# 显示器在左边还是右边
if [[ $1 -eq 'r' ]]; then
    right=1
fi

# 显示器状态的识别和配置
if [[ $dp == 0 && $hdmi == 0 ]]; then
    monitor=0                       # 只有笔记本身的显示器 
elif [[ $dp != 0 ]]; then
    if (( $right == 0 )); then
        monitor=10                  # DP 接口显示器, 左边
    else
        monitor=11                  # DP 接口显示器, 右边
    fi
else
    if (( $right == 0 )); then
        monitor=20                  # HDMI 接口显示器, 左边
    else
        monitor=21                  # HDMI 接口显示器, 右边
    fi
fi

# 调整显示器
case $monitor in
    0) xrandr --dpi 210 --fb 2560x1440 \
            --output eDP1 --mode 2560x1440 \
                --pos 0x0 --panning 2560x1440+0+0 ;;
    10) xrandr --dpi 210 --fb 5440x1620 \
            --output DP1 --scale 1.5x1.5 --mode 1920x1080 \
                --pos 0x0 --panning 2880x1620+0+0 \
            --output eDP1 --mode 2560x1440 --right-of DP1 \
                --panning 2560x1440+2880+0 ;;
    11) xrandr --dpi 210 --fb 5440x1620 \
            --output eDP1 --mode 2560x1440 \
                --pos 0x0 --panning 2560x1440+0+0 \
            --output DP1 --scale 1.5x1.5 --mode 1920x1080 \
                --right-of eDP1 --panning 2880x1620+2560+0;;
    20) xrandr --dpi 210 --fb 5080x1650 \
            --output HDMI2 --mode 2200x1650 \
                --pos 0x0 --panning 2200x1650+0+0 \
            --output eDP1 --mode 2560x1440 --right-of HDMI2 \
                --panning 2560x1440+2200+0 ;;
    21) xrandr --dpi 210 --fb 5080x1650 \
            --output eDP1 --mode 2560x1440 \
                --pos 0x0 --panning 2560x1440+0+0 \
            --output HDMI2 --mode 2200x1650  \
                --right-of eDP1 --panning 2200x1650+2560+0;;
    *) echo "error monitor setting" ;;
esac

