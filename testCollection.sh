#!/usr/bin/env bash

string="$(xsel -op | sed ':a; N; s/\n/ /g; ta' | sed -E 's/\s+/ /g')"
[[ -z "$string" ]] && { echo "没有复制文本" 1>&2; exit 1; }

file="$NUTSTORE/Diary/$(date +%y%m%d) testcollection.md"
if [ ! -f "$file" ]; then
    cat > "$file" << EOF
# $(date +%Y年%m月%d日) 摘录
EOF
fi
{
    echo ""
    echo "## ${*:-notitle}"
    echo ""
    echo "### 摘录时间：$(date +%H:%M:%S)"
    echo ""
    echo "$string"
} >> "$file"

