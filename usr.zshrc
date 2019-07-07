# 自定义启动脚本

N() {
	dir="$NUTSTORE/Diary"
    replace="no"

    # 处理参数
	while getopts hp:r opt
	do
		case "$opt" in
			h) dir="$(pwd)";;
			p) dir="$OPTARG";;
            r) replace="yes";;
			*) echo "Unknow option:: $opt";;
		esac
	done
	shift $[ $OPTIND - 1 ] 	# 移动参数

    # 处理文件名
	[[ $1 =~ '\.[A-Za-z0-9]+$' ]] && file="$1" || file="$1.md"
    title="${file%.*}"
    file="$(date +%y%m%d) $file"

	if [[ $replace == "yes" ]] || [[ ! -f "$dir/$file" ]]; then
        echo "---"                        > "$dir/$file"
        echo "title: ${title}"            >> "$dir/$file"
        echo "author: 罗伟"               >> "$dir/$file"
        echo "date: $(date +%Y-%m-%d)"    >> "$dir/$file"
        echo "---\n"                      >> "$dir/$file"
        echo "# ${title}\n"               >> "$dir/$file"
	fi
	
    if [[ "$(uname -s)" == "Linux" ]]; then
        xdg-open "$dir/$file"
    else 
        open "$dir/$file"	
    fi
}
