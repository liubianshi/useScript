#!/usr/bin/env bash

[[ -f ~/useScript/lf_icons.sh ]] && source ~/useScript/lf_icons.sh

# 自定义启动脚本
## 别名
alias D="~/useScript/testCollection.sh"
alias T='cd /tmp'
alias bm='buku --suggest'
alias book='~/useScript/bookdown_init.sh'
alias cat='bat'
alias dual='~/useScript/dual_monitors_laptop.sh'
alias ga='git add'
alias gm='git commit -m'
alias gpull='git pull'
alias gpush='git push'
alias gs='git status'
alias help='tldr'
alias ll='exa -alh'
alias mutt='proxychains -q neomutt'
alias open='xdg-open'
alias ss=proxychains
alias ssh0='ssh liubianshi_ali@118.190.162.170'
alias ssh1='ssh -oPort=6000 liubianshi@118.190.162.170'
alias stata='nohup /usr/local/bin/xstata-mp &'
alias tb='taskbook'
alias tmux='tmux a || tmux'
alias fdn='fd --changed-within=1d'
alias rmarkdown='~/useScript/rmarkdown.sh'
alias wt='curl wttr.in/Tianjin\?format=3'

lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}
bindkey -s '^o' 'lfcd\n'

temp () {
    cmd="nvim"
    files=""
    out="n"
	while getopts c:o opt
	do
		case "$opt" in
			c) cmd="$OPTARG";;
            o) out='y';;
			*) echo "Unknow option:: $opt";;
		esac
	done
    shift $(( OPTIND - 1 )) 	# 移动参数
    
    for arg in $@; do
        if [[ $files == "" ]]; then
            files="$(mktemp --suffix=.$arg)"
        else
            files="$files $(mktemp --suffix=.$arg)"
        fi
    done

    if [[ $files == "" ]]; then
        files=$(mktemp) 
    fi
    echo "$files"
    if [[ $out != "y" ]]; then
        $cmd $files
    fi
}



## 在日记文件夹快速新建并打开文件
N() {
	dir="$NUTSTORE/Diary"
    replace="no"

    # 处理参数
	while getopts hp:rx opt
	do
		case "$opt" in
			h) dir="$(pwd)";;
			p) dir="$OPTARG";;
            r) replace="yes";;
            x) xopen="yes";;
			*) echo "Unknow option:: $opt";;
		esac
	done
    shift $(( OPTIND - 1 )) 	# 移动参数

    # 处理文件名
    
	[[ $* =~ \.[A-Za-z0-9]+$ ]] && file="${*// /_}" || file="${*// /_}.md"
    title="${file%.*}"
    file="$(date +%y%m%d)_$file"

	if [[ $replace == "yes" ]] || [ ! -f "$dir/$file" ]; then
        echo "# ${title}\n" > "$dir/$file"
	fi
    
    if [[ "$xopen" == "yes" ]]; then
        if [[ "$(uname -s)" == "Linux" ]]; then
            xdg-open "$dir/$file"
        else 
            open "$dir/$file"	
        fi
    else
        vim "$dir/$file"
    fi
}


