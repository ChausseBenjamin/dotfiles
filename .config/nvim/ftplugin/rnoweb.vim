autocmd BufEnter * :UltiSnipsAddFiletypes tex.r

" Nvim-R
let R_rconsole_width = 0
let R_openpdf = 0
au BufWritePost *.rnw,      silent! :call RWeave("nobib", 1, 1)
au VimLeave    *.rnw !texclear %

