" Vim syntax file
" Language:    No language. Output additionals for stata 

runtime syntax/cmdlineoutput.vim

" Input
syn match cmdlineInput "^\. .*"

" Errors and warnings
syn match cmdlineError "^r\(.*\);"
