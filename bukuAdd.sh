#/usr/bin/env bash

set -e

inputUrl=$(xclip -o -sel clip)
 tags=$(zenity --forms --title="为网址添加标签和注释" \
     --text="$inputUrl" \
     --separator=" -c " \
     --add-entry="标签「以“,”分隔」" \
     --width=500 \
     --height=150)
if [[ -n "$tags" ]]; then
    error=$(proxychains -q buku -a $inputUrl $tags >/dev/null 2>&1)
    if [[ $error != "" ]]; then
        zenity --error --title="BukuAdd Error" \
            --text="$(echo $error | cut -f1 --complement -d' ')"
    else
        notify-send "bukuAdd" "$(buku -p -1 -f 4 | awk '{print $2}' )"
    fi
fi
