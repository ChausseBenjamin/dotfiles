"        _
"       (_)
" __   ___ _ __ ___  _ __ ___
" \ \ / / | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__
"   \_/ |_|_| |_| |_|_|  \___|
"
"

" Vim Plug {{{

" Autoinstall
let autoload_plug_path = stdpath('data') . '/site/autoload/plug.vim'
if !filereadable(autoload_plug_path)
  silent execute '!curl -fLo ' . autoload_plug_path . '  --create-dirs
      \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
unlet autoload_plug_path

" Plugins
call plug#begin()
" Bracket Completion
Plug 'jiangmiao/auto-pairs'
" Automated vim bulletpoints
Plug 'dkarter/bullets.vim'
" Vim css hex highlight
Plug 'chrisbra/Colorizer'
" Deoplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" LaTeX deoplete
Plug 'hisaknown/deoplete-latex'
" Todoist with vim?
Plug 'romgrk/todoist.nvim', { 'do': ':TodoistInstall' }
" markdown preview vim
Plug 'iamcco/markdown-preview.nvim'
" Nice markdown formatting
Plug 'godlygeek/tabular', { 'for': 'markdown' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
" Generate buffers
Plug 'AndrewRadev/bufferize.vim'
" Emmet
Plug 'mattn/emmet-vim', { 'for': [ 'markdown', 'html' ] }
" html preview
Plug 'turbio/bracey.vim', { 'for': [ 'html', 'stylesheet', 'javascript'] }
" My colorscheme
Plug 'ChausseBenjamin/friffle-vim'
" Elly colorscheme
Plug 'ryuta69/elly.vim'
" Vim Fugitive
Plug 'tpope/vim-fugitive'
" Vim-Surround
Plug 'tpope/vim-surround'
" Vim repeat for dot command on vim surround
Plug 'tpope/vim-repeat'
" Vimtex
Plug 'lervag/vimtex', { 'for': ['tex', 'aux', 'bib'] }
" Commentary
Plug 'tpope/vim-commentary'
" Vim snippet manager/tool
Plug 'sirver/UltiSnips'
" Vim snippet library
Plug 'honza/vim-snippets'
" French grammar checker
Plug 'dpelle/vim-Grammalecte'
" All purpose grammar checker
Plug 'dpelle/vim-LanguageTool'
" sxhkd syntax
Plug 'kovetskiy/sxhkd-vim', { 'for': 'sxhkdrc' }
" Google cal inside vim
Plug 'itchyny/calendar.vim'
" Turning vim into an R IDE
Plug 'jalvesaq/Nvim-R', { 'for': [ 'R', 'Rnoweb', 'tex', 'aux', 'bib' ] }
" csv filetype for vim
Plug 'chrisbra/csv.vim'
" Quick highlighting
Plug 'qxxxb/vim-searchhi'
" Split resizing made easy
Plug 'simeji/winresizer'
call plug#end()
" }}}

" Sensible defaults {{{
" Aesthetics & basics
syntax on
colo elly
hi Normal guibg=NONE
hi CursorLineNr guibg=NONE
set tgc " Use my terminal's colors
set lz " Lazy redraw -> Quicker vim
set t_Co=256 " 256 colors
set enc=utf-8
set wmnu " Display all matching file when we tab complete
set nosc " Don't show the previously typed command
set nu rnu " Ablolute Relative number hybrid
set ru " View column count
set ls=0 " Disable the statusline
set sb spr " Sensible split directions
set ts=2 " A sensible tab width
set shiftwidth=2 " A sensible tab width
set et " Expanding tabs
set foldmethod=marker " vim folding

" Completion
set path+=** " Provides tab-completion for all file related tasks
set wim=longest,list,full " set completion mode
set runtimepath+=~/.config/nvim/plugged/deoplete.nvim
let g:deoplete#enable_at_startup = 1

" Wrapping
set wrap
set lbr

" Custom semicolon leader
let mapleader=";"

" Spelling
set complete+=kspell " Better Spell Checking
set spl=fr " French prose

" Tag Editing
inoremap <leader>t <++>
inoremap <leader>: <Esc>/<++><CR>"_c4l

" Quickly save
nnoremap <silent> <Leader>w :update<CR>

" Logical way to Y ank
nnoremap Y y$

" Easily escape terminal mode
tnoremap <Esc> <C-\><C-n>

" Split motion
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Saving and quitting buffers
nnoremap ZF ZQ
nnoremap <silent> <leader>w :update<CR>

" Remove trailing white spaces
autocmd BufWritePre * %s/\s\+$//e

" }}}

" Workflow specific {{{

" 'o'pen pdf for the current document
nnoremap <silent> <leader>o :!opout <c-r>%<CR><CR>
nnoremap <silent> <leader>c :update \| :!compiler <c-r>%<CR><CR>
nnoremap <silent> <leader>r :update \| :!compiler <c-r>%<CR><CR> \| :!sage %:r.sagetex.sage && compiler %<CR><CR>

" }}}

" Plugin related {{{

" Todoist.nvim
let todoist = {
\ 'icons': {
\   'unchecked': ' ',
\   'checked':   ' ',
\   'loading':   ' ',
\   'error':     ' ',
\ },
\}

" Markdown syntax
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_folding_disabled = 1
set conceallevel=2

" Bufferize
let g:bufferize_command = 'vnew'

" Bracey
let g:bracey_browser_command = "firefox"

" Grammalecte
let g:grammalecte_cli_py = "/usr/bin/grammalecte-cli"

" Calendar.vim
let g:calendar_google_calendar = 1
let g:calendar_frame = 'default'
source ~/.cache/calendar.vim/credentials.vim

" Emmet.vim
let g:user_emmet_leader_key=','

" Vimtex
"  pdf viewer
   let g:vimtex_view_general_viewer = 'open'
   let g:vimtex_view_general_options = '-a zathura'
   let g:tex_flavor = 'latex'
"  TOC
   nnoremap <C-n> :VimtexTocToggle<cr>
"  Underscore errors
   let g:tex_no_error=1
"  Consistent conceal highlighting
   hi clear Conceal

" Nvim-R
"  Folding
   let r_syntax_folding = 1
   set foldnestmax=1
   set foldmethod=marker
"  Follow colorscheme
   let rout_follow_colorscheme = 0

" Arduino
let g:arduino_cmd = '/usr/bin/arduino'
let g:arduino_dir = '/usr/share/arduino'

" Ultisnips
let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger=";<Space>"
let g:UltiSnipsJumpBackwardTrigger=";n"
    " If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
" Snippet directory
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/UltiSnips']

" }}}

" See immediate results when edditing this file
autocmd BufWritePost ~/.config/nvim/init.vim :source %
