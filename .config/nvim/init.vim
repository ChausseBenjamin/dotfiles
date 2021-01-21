"        _
"       (_)
" __   ___ _ __ ___  _ __ ___
" \ \ / / | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__
"   \_/ |_|_| |_| |_|_|  \___|
"
"


" #---Plug Installer---# "
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" #---Vim Plugins---# "
call plug#begin()
" Deoplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Go Deoplete sources
Plug 'stamblerre/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'deoplete-plugins/deoplete-go', { 'do': 'make'}
" Automated vim bulletpoints
Plug 'dkarter/bullets.vim'
" Todoist with vim?
Plug 'ChausseBenjamin/todoist.nvim', { 'do': ':TodoistInstall' }
" LaTeX deoplete
Plug 'hisaknown/deoplete-latex'
" Turning vim into an R IDE
Plug 'jalvesaq/Nvim-R'
" Google cal inside vim
Plug 'itchyny/calendar.vim'
" Vim Sensible
Plug 'tpope/vim-sensible'
" Using vim to compile arduino code
Plug 'stevearc/vim-arduino'
" Vim org tables
Plug 'dhruvasagar/vim-table-mode'
" Vim css hex highlight
Plug 'chrisbra/Colorizer'
" Bracket Completion
Plug 'jiangmiao/auto-pairs'
" csv filetype for vim
Plug 'chrisbra/csv.vim'
" Go developement
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" sxhkd syntax
Plug 'kovetskiy/sxhkd-vim'
" Vim-Bling Search
Plug 'ivyl/vim-bling'
" Vim Hard Mode
Plug 'wikitopian/hardmode'
" Make vim behave like Jupyter
Plug 'metakirby5/codi.vim'
" markdown preview vim
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
" Emmet expansion for html
Plug 'mattn/emmet-vim'
" html preview
Plug 'turbio/bracey.vim'
" My colorscheme
Plug 'ChausseBenjamin/friffle-vim'
" Elly colorscheme
Plug 'ryuta69/elly.vim'
" Nord colorscheme
Plug 'arcticicestudio/nord-vim'
" Vim Fugitive
Plug 'tpope/vim-fugitive'
" Vim-Surround
Plug 'tpope/vim-surround'
" Vim repeat for dot command on vim surround
Plug 'tpope/vim-repeat'
" Vimtex
Plug 'lervag/vimtex'
" lightline
Plug 'itchyny/lightline.vim'
" Commentary
Plug 'tpope/vim-commentary'
" Vim markdown
Plug 'godlygeek/tabular'
" Ctrl-P fuzzy file finder
Plug 'ctrlpvim/ctrlp.vim'
" Vim snippet manager/tool
Plug 'sirver/UltiSnips'
" Vim snippet library
Plug 'honza/vim-snippets'
" Async shell commands
Plug 'skywind3000/asyncrun.vim'
" French grammar checker
Plug 'dpelle/vim-Grammalecte'
" All purpose grammar checker
Plug 'dpelle/vim-LanguageTool'
call plug#end()

" #---Basics/Recomended---# "
syntax on
filetype plugin on
set termguicolors
set lazyredraw
set t_Co=256
set encoding=utf-8
set path+=** " Provides tab-completion for all file related tasks
set wildmenu " Display all matching file when we tab complete
runtime macros/matchit.vim
" Spelling
set complete+=kspell " Better Spell Checking
set spelllang=fr
nnoremap ;h <Esc>zg
nnoremap ;j <Esc>]s
nnoremap ;k <Esc>[s
nnoremap ;l <Esc>z=1<CR><CR>
nnoremap ;<Space> <Esc>z=1<CR><CR>
" Enable autocompletion:
    set wildmode=longest,list,full
		set runtimepath+=~/.config/nvim/plugged/deoplete.nvim
    let g:deoplete#enable_at_startup = 1
" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow splitright
set rtp+=/usr/local/opt/fzf " Fuzzy File Finder
set t_vi= " Autohide the cursor
" Automatic wordwrap without creating newlines!
set wrap
set linebreak

" #---Plugin Preferences---# "
" Emmet Expansion
let g:user_emmet_leader_key=','
" MarkdownPreview
let g:mkdp_browser = 'firefox'
" Bracey
let g:bracey_browser_command = "firefox"
" Grammalecte path
let g:grammalecte_cli_py = "/usr/bin/grammalecte-cli"
" Ultisnips
    " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
    let g:UltiSnipsExpandTrigger="<Tab>"
    let g:UltiSnipsJumpForwardTrigger=";<Space>"
    let g:UltiSnipsJumpBackwardTrigger=";n"
    " If you want :UltiSnipsEdit to split your window.
    let g:UltiSnipsEditSplit="vertical"
    " Snippet directory
    let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/UltiSnips']
" Hexokinase
let g:Hexokinase_highlighters = ['virtual']
" Vimtex pdf viewer
let g:vimtex_view_general_viewer = 'open'
let g:vimtex_view_general_options = '-a zathura'
let g:tex_flavor = 'latex'
" Vimtex TOC
nnoremap <C-n> :VimtexTocToggle<cr>
" Calendar setup
let g:calendar_google_calendar = 1
let g:calendar_frame = 'default'
source ~/.cache/calendar.vim/credentials.vim

" #---Document Compilation/Visualisation---# "
" Compile document, be it groff/LaTeX/markdown/etc.
nnoremap <leader>c :w! \| AsyncRun compiler <c-r>%<CR><CR>
autocmd InsertLeave,TextChanged *.gd,*.ms,*.mom :w! | :execute 'silent AsyncRun compiler %'
" autocmd InsertLeave *.rmd,*.rnw,*.tex :w! | :execute 'silent AsyncRun compiler %; todotable % TODO FIXME CHANGED XXX IDEA HACK NOTE REVIEW NB BUG QUESTION COMBAK'
nnoremap <leader>x :w! \| AsyncRun todotable <c-r>% TODO FIXME CHANGED XXX IDEA HACK NOTE REVIEW NB BUG QUESTION COMBAK TEMP<CR><CR>
" Have dwmblocks automatically recompile and run when you edit this file in
autocmd BufWritePost ~/Compilation/dwmblocks/config.h !cd ~/Compilation/dwmblocks/; make && sudo make install && { killall -q dwmblocks;setsid dwmblocks & }
autocmd BufWritePost ~/.Xresources !xrdb -load %
" Open corresponding .pdf/.html or preview
    nnoremap <leader>p :! opout <c-r>%<CR><CR>
" Open corresponding .pdf/.html or preview
    nnoremap <leader>o :! tdout <c-r>%<CR><CR>
" Spaces are superior to tabs
set tabstop=2
set shiftwidth=2
set expandtab
" 80 col warning
" highlight ColorColumn ctermbg=magenta
" call matchadd('ColorColumn', '\%81v', 100)

" #---Custom Keymaps---# "
" Vim split resize
    map <Up>    <Esc>:resize<Space>+3<CR>
    map <Down>  <Esc>:resize<Space>-3<CR>
    map <Left>  <Esc>:vertical<Space>resize<Space>-3<CR>
    map <Right> <Esc>:vertical<Space>resize<Space>+3<CR>
    map <C-_>   <Esc>:split<CR>
    map <C-\>   <Esc>:vsplit<CR>
" Shortcutting split navigation, saving a keypress:
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l
" Easily escape terminal mode
tnoremap <Esc> <C-\><C-n>
" Space is my leader
nmap <Space> <Leader>
" Fastest save in the west
nnoremap <leader>w :w<CR>

" #---Visual Enhancements---# "
colorscheme friffle
" colorscheme friffle
" Remove latex underscore errors
let g:tex_no_error=1
" let g:airline_powerline_fonts = 1
" Lightline config
let g:lightline = {
      \ 'colorscheme': 'friffle',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \   },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \   },
      \ }
set noshowmode

" #---Ease Of Use---# "
" Normal/relative number toggle
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
" Remove all trailing spaces upon write {{{
autocmd BufWritePre * %s/\s\+$//e
" Soft Tabs
filetype plugin indent on
" Nvim-R send line
" nmap <C-Enter> <leader>l
" Nvim-R match colorscheme
let rout_follow_colorscheme = 0
" Nvim-R folding
    let r_syntax_folding = 1
    set foldnestmax=1
    set foldmethod=marker
" Arduino settings
let g:arduino_cmd = '/usr/bin/arduino'
let g:arduino_dir = '/usr/share/arduino'
" Vim fugitive settings
nmap <leader>gh :diffget //3<CR>
nmap <leader>gu :diffget //2<CR>
nmap <leader>gs :G<CR>
nmap <leader>gc :Gcommit<CR>
" Todoist icons
  let todoist = {
  \ 'icons': {
  \   'unchecked': ' ',
  \   'checked':   ' ',
  \   'loading':   ' ',
  \   'error':     ' ',
  \ },
  \}




" #---Universal Macros---# "
" Create and navigate Markers
" inoremap ;m <++>
inoremap ;; <Esc>/<++><CR>"_c4l
inoremap << «
inoremap >> »
" Spelling quickfixes
function! QuickFixSpell(dir)
  " -1 Means previous spelling err
  if a:dir == -1
    normal! ms[s1z=`s<cr>
  " 1 Means next spelling err
  elseif a:dir== 1
    :normal! ms]s1z=`s<cr>
  endif
  execute 'delmark s'
endfunction

nnoremap <s :call QuickFixSpell(-1)<cr>
nnoremap >s :call QuickFixSpell(1)<cr>

" Markdown Heading underline
function! UnderlineHeading(level)
  if a:level == 1
    execute "normal! yypVr=k$"
  elseif a:level == 2
    execute "normal! yypVr-k$"
  else
    execute "normal! I### \e$"
  endif
endfunction

nnoremap <leader>u1 :call UnderlineHeading(1)<cr>
nnoremap <leader>u2 :call UnderlineHeading(2)<cr>
nnoremap <leader>u3 :call UnderlineHeading(3)<cr>

" #---Filetype Specific Settings---# "
set runtimepath^=~/.vim/bundle/todoist.nvim
