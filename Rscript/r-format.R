#!/usr/bin/env Rscript
library("magrittr")
con <- file("stdin")
out <- styler::style_text(readLines(con), transformers = styler::tidyverse_style(strict = TRUE, indent_by = 4))
close(con)
out
