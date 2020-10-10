#!/usr/bin/env bash

#   Source 外部文件 {{{1
[ -e $HOME/.config/fpath ] || ln -s $HOME/Repositories/dotfiles/config/fpath $HOME/.config/fpath
fpath=("$HOME/.config/fpath" $fpath)
[[ -f "$HOME/useScript/lf_icons.sh" ]] && source "$HOME/useScript/lf_icons.sh"
source ~/useScript/alias

# ftpane - switch pane (@george-b) {{{1
ftpane() {
  local panes current_window current_pane target target_window target_pane
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')

  target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

  target_window=$(echo "$target" | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo "$target" | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
    tmux select-pane -t ${target_window}.${target_pane}
  else
    tmux select-pane -t ${target_window}.${target_pane} &&
    tmux select-window -t $target_window
  fi
}

#   通过 lf 切换目录 {{{1
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    [ -f "$tmp" ] || return 1
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    [ -d "$dir" ] || return 2
    [ "$dir" != "$(pwd)" ] && cd "$dir" || return 1
    return 0
}
bindkey -s '^o' 'lfcd\n'

#  快速跳转 {{{1
j() {
    [ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

v() {
    [ $# -gt 0 ] && fasd -f -e nvim "$*" && return
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && nvim "${file}" || return 1
}
fasd_cd() {
  if [ $# -le 1 ]; then
    fasd "$@"
  else
    local _fasd_ret="$(fasd -e 'printf %s' "$@")"
    [ -z "$_fasd_ret" ] && return
    [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || printf "%s\n" "$_fasd_ret"
  fi
}
alias z='fasd_cd -d'
alias zz='fasd_cd -d -i'
# 创建临时文件 {{{1
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
    
    for arg in "$@"; do
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
        $cmd "$files"
    fi
}

# 在日记文件夹快速新建并打开文件 {{{1
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
        $EDITOR "$dir/$file"
    fi
}
#}}}
# 查询 man 文档{{{1
fman() {
    man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man
}#}}}
# 快速查询 pdf 内容{{{1
fp () {
    open=xdg-open

    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:60% --preview '
            v=$(echo {q} | tr " " "|"); 
            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
        ' \
    | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open > /dev/null 2> /dev/null
}

# raku {{{1
export POD_TO_TEXT_ANSI=1 # using ANSI escape sequence on p6doc

# instapaper {{{1
export INSTAPAPER_USER='wei-luo@hotmail.com'
export INSTAPAPER_PASS=$(pass instapaper)

#sdcv 配置和字典文件 {{{1
export STARDICT_DATA_DIR="$NUTSTORE/Sync/sdcv_dict"

# fzf-bib {{{1
export FZF_BIBTEX_CACHEDIR="$HOME/.cache/fzf-bibtex/" # 出现意外错误，无法启动
export FZF_BIBTEX_SOURCES="$HOME/Documents/paper_ref.bib"

# 更改终端浏览器 {{{1
#export http_proxy=127.0.0.1:8118
#export https_proxy=$http_proxy
export BROWSER='/usr/bin/qutebrowser'

#   nnn 环境变量配置 {{{1
export NNN_OPTS="cE"
export NNN_COLORS='6321'
export NNN_FIFO="/tmp/nnn.fifo"
export NNN_SSHFS='sshfs -o reconnect,idmap=user'
NNN_BMS="$(tr "\n" ";" < ~/.local/share/lf/marks)"; export NNN_BMS;
export NNN_TRASH=1
export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
export NNN_PLUG='z:fasd;p:-nuke;P:-preview_tabbed;f:-fzcd;o:-fzopen'
export GUI=1

# to show video files, run: list video {{{2
list()
{
    fd -d 1 | file -if- | ag "$1" | awk -F: '{printf "./%s\0", $1}' | nnn -d
}

n () # cd on quit {{{2
{
    # Block nesting of nnn in subshells
    if [ -n "$NNNLVL" ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, remove the "export" as in:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # NOTE: NNN_TMPFILE is fixed, should not be modified
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

# SRDM {{{1 
export SRDM_DATA_MANAGER_ENGINE='SQLite'
export SRDM_DATA_MANAGER_PATH="$HOME/Documents/personal_database"

# 查询个人笔记 {{{1
#
,info() {
    ag $@ ~/.config/diySync
}

fnote() {
    search=$(mktemp /tmp/fnote.XXXXXXX.md)
    dir="$NUTSTORE"
    ag -H -G '\.(md|Rmd|rmd|raku|pl.|do|ado|R|r|markdown)$' $@ "$dir" > $search
    sed -Ei 's/:/\t\t/; s!/!# /!' $search
    sed -Ei 's!'$dir'/!!' $search
    sed -Ei '/^#/a
    ' $search
    nvim +'set tw=0 nowrap' +'normal zR' +'Leaderf! bufTag --all' $search
}

# cheat 配置 {{{1
export CHEAT_USE_FZF=true
[ -e $HOME/.config/cheat/cheat.zsh ] && source $HOME/.config/cheat/cheat.zsh
# 记录生词
stw() {
    ed=0
    while getopts ':e' opts; do
        case "$opts" in
            e) ed=1;;
            *) { echo "Usage: stw [-e] [<word>]"; return 1; };;
        esac
    done
    shift $((OPTIND-1))

    [ $# -ge 2 ] && { echo "Usage: stw [-e] [<word>]"; return 1; }
    [ $# -eq 1 ] && {
        trans_result=$(trans -b --no-auto "$1")
        stup add -c word -n "$1: $trans_result"
        echo "\033[32;4m$1: $trans_result\033[0m\n"
        unset trans_result
    }

    if [ $ed -eq 1 ]; then
        stup edit -c word
    else
        echo "\033[33;4;1mToday's Vocabulary:\033[0m"
        stup -c word | sed -ne '5,$p'
    fi
    unset ed
}
