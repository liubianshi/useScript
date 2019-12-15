inputUrl=$(xsel -ob)
tags=$(zenity --forms --title="为网址添加标签和注释" \
    --text="为 $inputUrl 添加标签和注释" \
    --separator=" -c " \
    --add-entry="标签「以“,”分隔」" \
    --add-entry="Comments" \
    --width=500 \
    --height=200)
if [[ -n "$tags" ]]; then
    error=$(buku -a $inputUrl $tags 2>&1 1>/dev/null)
    if [[ $error != "" ]]; then
        zenity --error --title="BukuAdd Error" \
            --text="$(echo $error | cut -f1 --complement -d' ')"
    else
        notify-send "bukuAdd" "$(buku -p -1 -f 4 | sed -n '2p')"
    fi
fi
