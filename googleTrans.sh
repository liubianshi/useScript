#!/usr/bin/env bash
to="zh"
inputTest=$(xclip -clip primary -o | sed ':a; N; s/\n/ /g; ta' |  sed -E 's/\s+/ /g')
file="$NUTSTORE/Sync/translate_back.Rmd"

while getopts t: opt; do
    case "$opt" in
        t) to=$OPTARG;;
        ?) echo "Unknow options:: $opt"
           exit 1;;
    esac
done
shift $(( OPTIND - 1 )) 	# 移动参数

outputTest="$(trans :$to -b \"$inputTest\")"
if [[ -n "$outputTest" ]]; then
    {
        echo "<!--$(date +%Y-%m-%d\ %H:%M:%S)-->"
        echo "$inputTest"
        echo ": $outputTest"
        echo ""
    } >> "$file"
    echo "$outputTest" | xsel -ib 
    notify-send -i "$NUTSTORE/Sync/icons/translate.png" -t 6000 "$outputTest" "$inputTest" 
else
    notify-send "Translage ERROR!"
fi

