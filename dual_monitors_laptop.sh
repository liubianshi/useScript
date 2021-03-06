#!/usr/bin/env bash

#set -e

# 参数说明{{{
# 使用两位数字表示
#    第一位数字表示笔记的显示器开启情况，
#    第二位数字表示笔记附显示开启情况
# 对于第一位数字，
#    0 表示不开启
#    1 表示开启，副显示器来自 DP 接口 
#    2 表示开启，副显示器来自 HDMI2 接口
# 对于副显示器的数字
#    0 不开启
#    1/2 开启，左边，没有放大
#    3/4 开启，右边，没有放大
#    5/6 开启，左边，放大 1.5 倍
#    7/8 开启，右边，放大 1.5 倍
#}}}
# 初始化变量{{{
dpi=210
scale=1.5
right=0
dp=0
hdmp=0

# get info from xrandr
xStatus=`xrandr`
connectedOutputs=$(echo "$xStatus" | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
activeOutput=$(echo "$xStatus" | grep -e " connected [^(]" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/") 
connected=$(echo $connectedOutputs | wc -w)

for display in $connectedOutputs
do
    if [[ $display = 'HDMI2' ]]; then
        hdmi=1
    fi
    if [[ $display = 'DP1' ]]; then
        hdmi=1
    fi
done

#}}}
# 参数处理{{{
if [ -z "$1" ]; then
    if (( dp == 0 && hdmi == 0 )); then
        monitor=0                       # 只有笔记本身的显示器 
    elif (( dp != 0 )); then
        if (( right == 0 )); then
            monitor=11                   # DP 接口显示器, 左边
        else
            monitor=13                  # DP 接口显示器, 右边
        fi
    else
        if (( right == 0 )); then
            monitor=12                  # HDMI 接口显示器, 左边
        else
            monitor=14                  # HDMI 接口显示器, 右边
        fi
    fi
else
    if (( dp == 0 && hdmi == 0 )); then
        echo "Only one monitor"
        exit 1
    fi
    if (( $# > 1 )); then
        echo "多于 1 个参数!"
        exit 1
    fi
    monitor=$1
fi
#}}}

# 根据参数设置显示模式{{{
case $monitor in
# 在 DP1 口外接显示器的情况
    0) xrandr --dpi $dpi --fb 2560x1440 \
            --output eDP1 --mode 2560x1440 --pos 0x0 --panning 2560x1440+0+0 \
            --output DP1 --off \
            --output HDMI2 --off ;;

    # 不开启
    10) xrandr --dpi $dpi --fb 2560x1440 \
            --output eDP1 --mode 2560x1440 --pos 0x0 --panning 2560x1440+0+0 \
            --output DP1 --off \
            --output HDMI2 --off ;;

    # 只使用外接显示器 dp1
    01) xrandr --dpi $dpi --fb 1920x1080 \
        --output DP1 --scale 1x1 --mode 1920x1080 \
            --pos 0x0 --panning 1920x1080+0+0 \
        --output eDP1 --off
    ;;

    # 只使用外接显示器 HDMI2
    02) xrandr --dpi $dpi --fb 3840x2160 \
        --output HDMI2 --scale 1x1 --mode 3840x2160 \
            --pos 0x0 --panning 3840x2160 \
        --output eDP1 --off
    ;;

    05) xrandr --dpi $dpi --fb 2880x1620 \
        --output DP1 --scale ${scale}x${scale} --mode 1920x1080 \
            --pos 0x0 --panning 2880x1620+0+0 \
        --output eDP1 --off
    ;;
    # 在左边使用外接显示器
    11) xrandr --dpi $dpi --fb 4480x1440 \
        --output DP1 --scale 1x1 --mode 1920x1080 \
            --pos 0x0 --panning 1920x1080+0+0 \
        --output eDP1 --mode 2560x1440 --right-of DP1 \
            --panning 2560x1440+1920+0
    ;;
    13) xrandr --dpi $dpi --fb 4480x1440 \
        --output eDP1 --mode 2560x1440 \
            --pos 0x0 --panning 2560x1440+0+0 \
        --output DP1 --scale 1x1 --mode 1920x1080 \
            --right-of eDP1 --panning 1920x1080+2560+0
    ;;
    15) xrandr --dpi $dpi --fb 5440x1620 \
        --output DP1 --scale ${scale}x${scale} --mode 1920x1080 \
            --pos 0x0 --panning 2880x1620+0+0 \
        --output eDP1 --mode 2560x1440 --right-of DP1 \
            --panning 2560x1440+2880+0
    ;;
    17) xrandr --dpi $dpi --fb 5440x1620 \
            --output eDP1 --mode 2560x1440 \
                --pos 0x0 --panning 2560x1440+0+0 \
            --output DP1 --scale ${scale}x${scale} --mode 1920x1080 \
                --right-of eDP1 --panning 2880x1620+2560+0
    ;;
    12) xrandr --dpi 210 --fb 6400x2160 \
            --output HDMI2 --mode 3840x2160 \
                --pos 0x0 --panning 3840x2160+0+0 \
            --output eDP1 --mode 2560x1440 --right-of HDMI2 \
                --panning 2560x1440+3840+0
    ;;

    14) xrandr --dpi 210 --fb 6400x2160 \
            --output eDP1 --mode 2560x1440 --pos 0x0 \
                --panning 2560x1440+0+0 \
            --output HDMI2 --mode 3840x2160 \
                --right-of eDP1 --panning 3840x2160+2560+0
    ;;
    *) echo "error monitor setting"; exit 1 ;;
esac
#}}}
echo "显示器设置完成"
exit 0
