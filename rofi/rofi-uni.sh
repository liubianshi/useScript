#!/usr/bin/env bash

#> uni_history 历史文件
uni_history="${NUTSTORE}/Sync/uni_history"
options='-columns 3 -width 90 -lines 20 -bw 2 -yoffset -2 -location 1'
choosed=$(cat "$uni_history" | rofi -dmenu -i -p "Input or Select: " $options)

# exit if nothing is selected
[[ -z $choosed ]] && exit

# 判断是否选中合适的 Unicode
select=$(echo $choosed | grep -Eic "u\+\w{5}")

# 如果选中, 直接给出 unicode 符号
if (( $select == 1 )); then
    result=$(echo $choosed | perl -alne 'print $F[0]')
# 如果没有选中, 通过 Uni 查询, 并重新选择, 然后将新的选择放入历史文件
else
    choosed=$(uni $choosed | rofi -dmenu -i -p "Select Unicode: " $options)
    [[ -z $choosed ]] && exit
    result=$(echo $choosed | perl -alne 'print $F[0]')
    sed -Ei -e "1i\\$choosed" -e '/^\s*$/d' "$uni_history"
fi

# 将挑选的 unicode 放入剪切版
echo -ne $result | xclip -selection clipboard



