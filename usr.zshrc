#!/usr/bin/env bash

[[ -f ~/useScript/lf_icons.sh ]] && source ~/useScript/lf_icons.sh

# 自定义启动脚本
## 别名
# git 相关{{{
alias ga='git add'
alias gm='git commit -m'
alias gpull='git pull'
alias gpush='git push -u origin master'
alias gs='git status'
#}}}
# ssh 相关{{{
alias ssh0='ssh liubianshi_ali@118.190.162.170'
alias ssh1='ssh -oPort=6000 liubianshi@118.190.162.170'
#}}}
# 下载相 关{{{
alias y='youtube-dl'
alias yx='youtube-dl -x'     # 以最佳质量仅下载音频
alias ya='youtube-dl -a'     # 下载文件中链接
alias yd='youtube-dl --write-info-json --write-annotations --write-sub --write-thumbnail --skip-download'
alias yl='youtube-dl --playlist-items'
alias 2p='wkhtmltopdf --proxy "http://127.0.0.1:8118" -L 20mm -R 20mm -T 20mm -B 20mm --no-background --user-style-sheet "$NUTSTORE/Sync/css/gruvbox-all-sites.css"'
alias bdy='baidupcs'
#}}}

# 快捷命令
alias tb='taskbook'
alias ss=proxychains
alias bm='buku --suggest'
alias mutt='proxychains -q neomutt'
alias stata='nohup /usr/local/bin/xstata-mp &'
alias tmuxa='tmux a || tmux'
alias cat='bat'
alias ll='exa -alh'
alias open='xdg-open'
alias wt='curl wttr.in/Tianjin\?format=3'

alias D="~/useScript/testCollection.sh"
alias T='cd /tmp'
alias book='~/useScript/bookdown_init.sh'
alias dual='~/useScript/dual_monitors_laptop.sh'
alias help='ss -q tldr'
alias fdn='fd --changed-within=1d'
alias rmarkdown='~/useScript/rmarkdown.sh'
alias v='f -e nvim'

# 文件开素导航{{{
alias lfd='lf ~/Downloads'
alias cdd='cd ~/Downloads'
alias lfr='lf "$NUTSTORE/Diary"'
alias cdr='cd "$NUTSTORE/Diary"'
alias lfw='lf "$NUTSTORE/工作相关"'
alias cdw='cd "$NUTSTORE/工作相关"'
alias lfb='lf "$NUTSTORE/文档/电子资料"'
alias cdb='cd "$NUTSTORE/文档/电子资料"'
alias lfm='lf ~/Movies'
alias cdm='cd ~/Movies'
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
#}}}

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

# raku
export POD_TO_TEXT_ANSI=1 # using ANSI escape sequence on p6doc

# instapaper
export INSTAPAPER_USER='wei-luo@hotmail.com'
export INSTAPAPER_PASS=$(pass instapaper)
