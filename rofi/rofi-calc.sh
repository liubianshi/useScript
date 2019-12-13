#!/usr/bin/env bash

rofi -show calc -modi calc -no-show-match -no-sort \
    -calc-command "printf '{result}' | xsel -ib"
