#!/usr/bin/env bash

name="$(basename "$1")"
name="${name%.*}"
trap 'rm "$HOME/Documents/Digest/${name}.md"' 15 9 0

sed -Ei '/资料来源/d' "$HOME/Documents/Digest/${name}.md"
sed -Ei '/^:<http/d' "$HOME/Documents/Digest/${name}.md"
"$HOME/.local/bin/md2" docx "$HOME/Documents/Digest/${name}.md"
mv "$HOME/Documents/Digest/$name.docx" "$NUTSTORE/工作相关/20201212 中心网站英文资料"
exit 0

