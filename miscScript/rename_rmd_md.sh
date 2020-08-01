#!/usr/bin/env bash

for file in **/*; do
    echo "$file"
    if [[ $file =~ \.[Rr]md$ ]]; then
        echo $file
        echo "$file" "\t" "${file%.[Rr]md}.md"
    fi
done


