#!/usr/bin/env sh

#> uni_history 历史文件和 Nerd Font
uni_history="$HOME/.config/diySync/uni_history"
nerd_chars="$HOME/.config/diySync/nerd-font-chars"
emoji_chars="$HOME/.config/diySync/emoji-chars"
uni_chars="$HOME/.config/diySync/uniname"

#options='-columns 3 -width 100 -lines 15 -bw 2 -yoffset -2 -location 1'
#choosed=$(cat "$uni_history" | rofi -dmenu -i -p "Input or Select: " $options)
choosed=$(cat "$uni_history" | dmenu -i -l 20 -p "Input/Select")

# exit if nothing is selected
[ -z $choosed ] && exit

# 判断是否选中合适的 Unicode
select=$(echo $choosed | grep -Eic "u\+\w{4,5}")

# 如果选中, 直接给出 unicode 符号
if [ $select -eq 1 ]; then
    result=$(echo $choosed | perl -alne 'print $F[0]')
else
    while [ $select -ne 1 ]; do
        choosed=$(echo $choosed | tr 'A-Z' 'a-z' | sed -E 's/\s+/\|/g; s/\|u$/ U/; s/\|e$/ E/')
        select2=$(echo $choosed | grep -Eo "[UE]$")
        case $select2 in
            U)  choosed=$(\
                ( [ -f $uni_chars ] && grep -Ei "${choosed% [Uu]}" "$uni_chars" || uni "${choosed% [Uu]}" )  |\
                    dmenu -i -l 20 -p  "Unicode" \
                );;
            E) choosed=$(grep -Ei "${choosed% [Ee]}" "$emoji_chars" |\
                    dmenu -i -l 20 -p "Emoji");;
            *) choosed=$(grep -Ei "$choosed" "$nerd_chars" |\
                    dmenu -i -l 20 -p "NerdFont");;
        esac
        [ -z $choosed ] && exit
        select=$(echo $choosed | grep -Eic "u\+\w{4,5}")
    done
    [ -z $choosed ] && exit
    result=$(echo $choosed | perl -alne 'print $F[0]')
    sed -Ei -e "1i\\$choosed" -e '/^\s*$/d' "$uni_history"
fi

# 将挑选的 unicode 放入剪切版
printf $result | xclip -selection clipboard

    


