#!/usr/bin/env bash

mkdir "$1" && cd "$1"

# basic files 
touch index.Rmd
touch ref.bib
cp ~/useScript/bookdown/_bookdown.yml .
cp ~/useScript/bookdown/_output.yml .
cp ~/useScript/bookdown/_build.sh .
chmod +x ./_build.sh

# latex related files
mkdir latex 
cp ~/useScript/header.tex latex
cp ~/useScript/code.tex latex
cp ~/useScript/default-rmd.latex latex

# html related files
mkdir css
cp ~/useScript/vue.css css

# bibtex related files
cp ~/useScript/cls/WorldEconomy.csl .

# start 
nvim ./index.Rmd
