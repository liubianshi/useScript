#!/usr/bin/env bash

# newfile: 将内容写入文件 {{{1
newfile () {
    local info
    local title
    local author
    local infosource
    local note
    local metadata
    local content

    content="$1"
    info=$(zenity --forms --title="补全摘录信息" \
        --text="补全摘录信息" \
        --separator="|" \
        --add-entry="标题" \
        --add-entry="作者" \
        --add-entry="来源" \
        --add-entry="备注" \
        --width=800)
    title=$(echo "$info" | cut -f1 -d'|')
    author=$(echo "$info" | cut -f2 -d'|')
    infosource=$(echo "$info" | cut -f3 -d'|')
    note=$(echo "$info" | cut -f4 -d'|')
    if [[ $title == "" || $author == "" ]]; then
        zenity --error --title="信息补全" --text="标题和作者信息必须完全！"
        exit 1
    fi
    
    metadata=$(cat <<-META
		# $title
		
		| author: $author
		| date: $(date +%F)
		META
    )
    [[ -n $note ]] && metadata="$metadata\n| 注释：$note."
    [[ -n $infosource ]] && metadata="$metadata\n| 资料来源：$infosource. $(date +%F)."

    echo -e "\n$metadata\n\n$content\n"

    return 0
}
#}}}

digestDir=${digestDir:-"$HOME/Documents/Digest/Fragment"}
filename="Digest_$(date +%y%m%d).Rmd"
imagename="${imagename:-image_$(date +%y%m%d_%H%M%S).png}"
icon="$NUTSTORE/Sync/icons/data-collecting.png"
mkdir -p "$digestDir/.assets"
cd "$digestDir" || exit 1

while getopts :cid:t: opt; do
    case "$opt" in
        c) conti=1;;
        i) image=1;;
        t) texttype="$OPTARG";;
        d) digestDir="$OPTARG";;
        ?) echo "Unknow options:: $opt"
           exit 1;;
    esac
done
shift $(( OPTIND - 1 )) 	# 移动参数

texttype=${texttype:-"html"}
if [ -z $image ] || [ $image -ne 1 ]; then
    if [ "$texttype" = "html" ]; then
        content=$(xclip -o -t text/html -sel clip | pandoc -f html -t markdown_strict)
    else
        content=$(xclip -o -sel clip | pandoc -t markdown_strict)
    fi
else
    xclip -sel clip -t image/png -o > ".assets/$imagename" || {
        zenity --error --title="图片保存失败" --text="请检查剪切版中的图片！"
        exit 1
    }
    content=$(cat <<-EOF
		\`\`\`{r, out.width = "70%%", fig.pos = "h", echo = F, dpi = 600}
		knitr::include_graphics(".assets/$imagename")
		\`\`\`
		EOF
    )
fi

[[ -z "$content" ]] && { notify-send -i "$icon" "ERROR" "Collect Fail!"; exit 1; }
content="## 摘录时间: $(date +%T)\n\n$content"

[ -f "$filename" ] || cat <<-META > "$filename"
	---
	title: 资料摘录
	author: liubianshi
	date: $(date +%F)
	---
	META
if [ -z $conti ] || [ $conti -ne 1 ]; then
    newfile "$content" >> "$filename"
else
    echo -e "\n$content\n" >> "$filename"
fi

notify-send -i "$icon" "Collect Successfully" "$content"
printf "%s" "$digestDir/$filename" | xclip -i -sel primary
exit 0

