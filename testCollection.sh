#!/usr/bin/env bash

conti=0
image=0
file="$DIY_COLLECT"

while getopts ci opt; do
    case "$opt" in
        c) conti=1;;
        i) image=1;;
        ?) echo "Unknow options:: $opt"
           exit 1;;
    esac
done
shift $(( OPTIND - 1 )) 	# 移动参数

if [[ $image == 0 ]]; then
    string="$(xsel -op | sed ':a; N; s/\n/ /g; ta' | sed -E 's/\s+/ /g')"
    [[ -z "$string" ]] && { echo "没有复制文本" 1>&2; exit 1; }
else
    filename="image_$(date +%y%m%d_%H%M%S).png"
    xclip -sel c -t image/png -o > "$NUTSTORE/Sync/.assets/$filename"
    if [[ $? != 0 ]]; then
        zenity --error --title="图片保存失败" \
                --text="请检查剪切版中的图片！"
            exit 1
    fi
    echo "$NUTSTORE/Sync/.assets/$filename" | xclip -sel clip
    #string="![](.assets/$filename)\n    "
    string1='```{r, out.width = "70%%", fig.pos = "h", fig.show = "hold"}'
    string2="knitr::include_graphics('.assets/$filename')"
    string3='```'
    indent='    '
fi

if [[ "$conti" == 0 ]]; then
    {
        info=$(zenity --forms --title="补全摘录信息" \
            --text="补全摘录信息" \
            --separator="|" \
            --add-entry="标题" \
            --add-entry="作者" \
            --add-entry="来源" \
            --add-entry="备注" \
            --width=800)
        Title=$(echo $info | cut -f1 -d'|')
        Author=$(echo $info | cut -f2 -d'|')
        Source=$(echo $info | cut -f3 -d'|')
        Note=$(echo $info | cut -f4 -d'|')
        if [[ $Title == "" || $Author == "" ]]; then
            zenity --error --title="信息补全" \
                --text="标题和作者信息必须完全！"
            exit 1
        fi
        
        # 处理标题
        if [[ ! $(grep -E -c "^# $(date +%Y)" "$file") > 0 ]]; then
            printf "# $(date +%Y)\n\n## $(date +%Y%m)\n\n### $(date +%Y%m%d)\n\n"
        else
            if [[ ! $(grep -E -c "^## $(date +%Y%m)" "$file") > 0 ]]; then
                printf "## $(date +%Y%m)\n\n### $(date +%Y%m%d)\n\n"
            else
                if [[ ! $(grep -E -c "^### $(date +%Y%m%d)" "$file") > 0 ]]; then
                    printf "### $(date +%Y%m%d)\n\n"
                fi
            fi
        fi
        printf "1. $Title [$(date +%Y-%m-%d)]\n: 作者：$Author"
        if [[ "$Note" != "" ]]; then
            printf "^[资料来源：$Source. $(date +%Y-%m-%d).]\n\n"
        else
            printf "\n\n"
        fi
        printf "$indent$string1\n"
        printf "$indent$string2\n"
        printf "$indent$string3\n"
        printf "$indent"
        if [[ "$Note" != "" ]]; then
            printf "^[注释：$Note.]<!--$(date +%Y-%m-%d\ %H:%M:%S)-->\n"
        else
            printf "<!--$(date +%Y-%m-%d\ %H:%M:%S)-->\n"
        fi
        echo ""
    } >> "$file"
    if [[ $? == 0 ]]; then
        notify-send -i "$NUTSTORE/Sync/icons/data-collecting.png" "Collect Successfully" "$string"
    else
        notify-send -i "$NUTSTORE/Sync/icons/data-collecting.png" "ERROR" "Collect Fail!"
    fi
else 
    {
        printf "$indent$string1\n"
        printf "$indent$string2\n"
        printf "$indent$string3\n"
        printf "$indent"
        printf "<!--$(date +%Y-%m-%d\ %H:%M:%S)-->\n\n"
    } >> "$file"
    if [[ $? == 0 ]]; then
        notify-send -i "$NUTSTORE/Sync/icons/data-collecting.png" "Collect Successfully" "$string"
    else
        notify-send -i "$NUTSTORE/Sync/icons/data-collecting.png" "ERROR" "Collect Fail!"
    fi
fi

