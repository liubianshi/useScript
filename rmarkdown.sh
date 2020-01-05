#!/usr/bin/env bash

set -ev

package='rmarkdown'
func='render'
output_format='bookdown::pdf_document2'
while getopts p:f:o: opt; do
    case "$opt" in
        p) package="$OPTARG";;
        f) func="$OPTARG";;
        o) output_format="$OPTARG";;
        *) echo "Unknow Option:: $optA"
           exit;;
    esac
done
shift $(( OPTIND - 1 ))
file=$*
[[ "$package" != "rmarkdown" ]] && output_format="$package::$output_format"

echo "$package::$func('$file', '$output_format')"
Rscript -e "$package::$func('$file', '$output_format')"


