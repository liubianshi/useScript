" 扩展 jalvesaq/vimcmdline 的语言覆盖范围
" 增加对 Stata 的支持
" 文件以软链接的形式放至 ~/.local/share/nvim/plugged/vimcmdline/ftplugin/
" 参考 https://github.com/jalvesaq/vimcmdline/blob/master/ftplugin/sh_cmdline.vim

" Ensure that plugin/vimcmdline.vim was sourced
if !exists("g:cmdline_job")
    runtime plugin/vimcmdline.vim
endif

function! StataSourceLines(lines)
    call writefile(a:lines, g:cmdline_tmp_dir . "/lines.do")
    call VimCmdLineSendCmd("do " . g:cmdline_tmp_dir . "/lines.do")
endfunction

let b:cmdline_nl = "\n"
let b:cmdline_app = "stata-se"
let b:cmdline_quit_cmd = "exit"
let b:cmdline_source_fun = function("StataSourceLines")
let b:cmdline_send_empty = 0
let b:cmdline_filetype = "stata"

exe 'nmap <buffer><silent> ' . g:cmdline_map_start . ' :call VimCmdLineStartApp()<CR>'

call VimCmdLineSetApp("stata")

