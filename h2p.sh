#!/usr/bin/env bash

css_path="$HOME/Nutstore Files/Nutstore/Sync/css"
css_file="html-to-pdf.css"

[[ "$1" =~ raku\.org/ ]] && css_file='raku.org.css'
echo "$css_file"

/usr/bin/wkhtmltopdf \
    --proxy "http://127.0.0.1:8118" \
    -L 20mm -R 20mm -T 20mm -B 20mm --no-background \
    --user-style-sheet "$css_path/$css_file" \
    "$1" "$HOME/Downloads/${2}.pdf"

echo "Succeed!"

exit 0


