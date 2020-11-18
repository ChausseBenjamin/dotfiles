" Nvim-R
let R_rconsole_width = 0
let R_openpdf = 0
au BufWritePost *.rmd      silent! :call RWeave("nobib", 1, 1)
au VimLeave    *.rmd !texclear %

