" Go deoplete
let g:deoplete#sources#go#gocode_binary = '$GOPATH/bin/gocode'
" GoRun Split Reuse
function! ReuseVimGoTerm(cmd) abort
    for w in nvim_list_wins()
        if "goterm" == nvim_buf_get_option(nvim_win_get_buf(w), 'filetype')
            call nvim_win_close(w, v:true)
            break
        endif
    endfor
    execute a:cmd
endfunction
let g:go_term_enabled = 1
let g:go_term_mode = "silent keepalt rightbelow 35 vsplit"
let g:go_def_reuse_buffer = 1
autocmd FileType go nmap <leader>r :call ReuseVimGoTerm('GoRun')<Return>

