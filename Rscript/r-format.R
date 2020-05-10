#!/usr/bin/env Rscript
library("magrittr")
con <- file("stdin")
out <- styler::style_text(readLines(con), strict = FALSE)
close(con)
out
