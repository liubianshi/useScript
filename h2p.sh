#!/usr/bin/env bash

# proxy seting
proxy=
while getopts ':p:' OPT; do
    case $OPT in
        p) if [ -z "$OPTARG" ]; then
                proxy="--proxy http://127.0.0.1:8118"
           else
                proxy="--proxy $OPTARG"
           fi
           ;;
        *) echo "Usage: $(basename "$0") [-p [<proxy>]] url filename";;
    esac
done


# css setting
css_path="$HOME/Nutstore Files/Nutstore/Sync/css"
css_file="html-to-pdf.css"
[[ "$1" =~ raku\.org/ ]] && css_file='raku.org.css'
[[ "$1" =~ raku\.guide/ ]] && css_file='raku.org.css'

/usr/bin/wkhtmltopdf "$proxy" \
    -L 20mm -R 20mm -T 20mm -B 20mm --no-background \
    --user-style-sheet "$css_path/$css_file" \
    "$1" "$HOME/Downloads/${2}.pdf"

echo "Succeed!"

exit 0


