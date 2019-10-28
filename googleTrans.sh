#!/usr/bin/bash

inputTest=$(xsel -op | sed ':a; N; s/\n/ /g; ta' |  sed -E 's/\s+/ /g')
outputTest=$(trans -b "$inputTest")
if [[ ! -z "$outputTest" ]]; then
    echo "$outputTest" | xsel -ib 
    notify-send  "$outputTest" --icon=edit-copy
else
    notify-send "Translage ERROR!"
fi

