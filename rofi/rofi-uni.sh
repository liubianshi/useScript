#!/usr/bin/env bash

#> uni_history 历史文件和 Nerd Font
uni_history="${NUTSTORE}/Sync/uni_history"
nerd_chars="${NUTSTORE}/Sync/nerd-font-chars"
emoji_chars="${NUTSTORE}/Sync/emoji-chars"

options='-columns 2 -width 90 -lines 20 -bw 2 -yoffset -2 -location 1'
choosed=$(cat "$uni_history" | rofi -dmenu -i -p "Input or Select: " $options)

# exit if nothing is selected
[[ -z $choosed ]] && exit

# 判断是否选中合适的 Unicode
select=$(echo $choosed | grep -Eic "u\+\w{4,5}")

# 如果选中, 直接给出 unicode 符号
if (( $select == 1 )); then
    result=$(echo $choosed | perl -alne 'print $F[0]')
else
    while (( $select != 1 )); do
        select2=$(echo $choosed | grep -Eio "[ue]$" | tr 'a-z' 'A-Z')
        case $select2 in
            U) choosed=$(uni "${choosed% [Uu]}" |\
                        rofi -dmenu -i -p "Select Unicode: " $options);;
            E) choosed=$(grep -i "${choosed% [Ee]}" "$emoji_chars" |\
                        rofi -dmenu -i -p "Select Unicode: " $options);;
            *) choosed=$(grep -i "$choosed" "$nerd_chars" |\
                        rofi -dmenu -i -p "Select Unicode: " $options);;
        esac
    [[ -z $choosed ]] && exit
        select=$(echo $choosed | grep -Eic "u\+\w{4,5}")
    done
    [[ -z $choosed ]] && exit
    result=$(echo $choosed | perl -alne 'print $F[0]')
    sed -Ei -e "1i\\$choosed" -e '/^\s*$/d' "$uni_history"
fi

# 将挑选的 unicode 放入剪切版
echo -ne $result | xclip -selection clipboard

    


