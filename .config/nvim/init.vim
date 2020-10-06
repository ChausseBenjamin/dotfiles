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
" if has('nvim')
  " Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" else
  " Plug 'Shougo/deoplete.nvim'
  " Plug 'roxma/nvim-yarp'
  " Plug 'roxma/vim-hug-neovim-rpc'
" endif
" Latex Deoplete source
" Plug 'hisaknown/deoplete-latex'
" Comment frames (for comment aesthetics)
Plug 'cometsong/CommentFrame.vim'
" Deoplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Go Deoplete sources
Plug 'stamblerre/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'deoplete-plugins/deoplete-go', { 'do': 'make'}
" LaTeX deoplete
Plug 'hisaknown/deoplete-latex'
" Turning vim into an R IDE
Plug 'jalvesaq/Nvim-R'
" Vim Sensible
Plug 'tpope/vim-sensible'
" Vim org tables
Plug 'dhruvasagar/vim-table-mode'
" Html linter enabler (for prettier AUR package)
Plug 'dense-analysis/ale'
" Vim Goyo
Plug 'junegunn/goyo.vim'
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
" I want to be a python ninja!
Plug 'metakirby5/codi.vim'
" Quickrun for python
Plug 'thinca/vim-quickrun'
" markdown preview vim
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
" Emmet expansion for html
Plug 'mattn/emmet-vim'
" html preview
Plug 'turbio/bracey.vim'
" VimCompletesMe for VimTex
Plug 'ajh17/VimCompletesMe'
" Xresources colors
Plug 'dylanaraps/wal.vim'
" Nord colors
Plug 'arcticicestudio/nord-vim'
" My personal colorscheme
Plug 'ChausseBenjamin/friffle-vim'
" Vim Fugitive
Plug 'tpope/vim-fugitive'
" Vim-Surround
Plug 'tpope/vim-surround'
" Vim repeat for dot command on vim surround
Plug 'tpope/vim-repeat'
" Vimtex
Plug 'lervag/vimtex'
" C developement in vim
Plug 'vim-scripts/c.vim'
" NERDTree
Plug 'scrooloose/nerdtree'
" Git plugin for NERDTree
Plug 'Xuyuanp/nerdtree-git-plugin'
" Icons in NERDTree and Airline
Plug 'ryanoasis/vim-devicons'
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
set t_Co=256
set encoding=utf-8
set path+=** " Provides tab-completion for all file related tasks
set wildmenu " Display all matching file when we tab complete
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
" Nvim-R
let R_rconsole_width = 0
" Emmet Expansion
let g:user_emmet_leader_key=','
" Enable kite autocompletion
let g:kite_auto_complete=1
" MarkdownPreview
" let g:mkdp_browser = 'surf'
" Bracey
let g:bracey_browser_command = "chromium"
" Grammalecte path
let g:grammalecte_cli_py = "/usr/bin/grammalecte-cli"
" Ale Linter with prettier
let g:ale_linters_explicit = 1
" autocmd BufWrite, *.css,*.html,*.js :ALEFix prettier
" Ultisnips
    " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
    let g:UltiSnipsExpandTrigger="<Tab>"
    let g:UltiSnipsJumpForwardTrigger=";<Space>"
    let g:UltiSnipsJumpBackwardTrigger=";n"
    " If you want :UltiSnipsEdit to split your window.
    let g:UltiSnipsEditSplit="vertical"
    " Snippet directory
    let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/UltiSnips']
" Go deoplete
let g:deoplete#sources#go#gocode_binary = '$GOPATH/bin/gocode'
" Hexokinase
let g:Hexokinase_highlighters = ['virtual']
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
" Vimtex pdf viewer
let g:latex_view_general_viewer = 'zathura'
let g:vimtex_view_method = "zathura"
let g:tex_flavor = 'latex'

" #---Document Compilation/Visualisation---# "
" Compile document, be it groff/LaTeX/markdown/etc.
map <leader>c :w! \| AsyncRun compiler <c-r>%<CR><CR>
autocmd InsertLeave,TextChanged *.gd,*.ms,*.mom :w! | :execute 'silent AsyncRun compiler %'
" autocmd InsertLeave *.rmd,*.rnw,*.tex :w! | :execute 'silent AsyncRun compiler %; todotable % TODO FIXME CHANGED XXX IDEA HACK NOTE REVIEW NB BUG QUESTION COMBAK'
autocmd VimLeave *.rmd,*.rnw,*.tex !texclear %
map <leader>x :w! \| AsyncRun todotable <c-r>% TODO FIXME CHANGED XXX IDEA HACK NOTE REVIEW NB BUG QUESTION COMBAK TEMP<CR><CR>
" Have dwmblocks automatically recompile and run when you edit this file in
autocmd BufWritePost ~/compilation/dwmblocks/config.h !cd ~/compilation/dwmblocks/; sudo make install && { killall -q dwmblocks;setsid dwmblocks & }
" Open corresponding .pdf/.html or preview
    map <leader>p :! opout <c-r>%<CR><CR>
" Open corresponding .pdf/.html or preview
    map <leader>o :! tdout <c-r>%<CR><CR>
" Width tabstop
set tabstop=2
" when indenting with '>', use 4 spaces width
set shiftwidth=2

" #---Custom Keymaps---# "
" Tab Buffer Navigation
    nnoremap <S-k> :bp<CR>
    nnoremap <S-j> :bn<CR>
" Vim split resize
    map <Up>    <Esc>:resize<Space>+3<CR>
    map <Down>  <Esc>:resize<Space>-3<CR>
    map <Left>  <Esc>:vertical<Space>resize<Space>-3<CR>
    map <Right> <Esc>:vertical<Space>resize<Space>+3<CR>
    map <C-_>   <Esc>:split<CR>
    map <C-\>   <Esc>:vsplit<CR>
" Ninja python execution
    map <F5>    <Esc>:Codi!!<CR>
    map <F6>    <Esc>:QuickRun<CR>
" Shortcutting split navigation, saving a keypress:
    map <C-h> <C-w>h
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-l> <C-w>l
" Create blank lines using Shift J and Shift K
    nnoremap J o<Esc>
    nnoremap K O<Esc>
" Figlet dotfile titles
command RcTitle .!figlet -s -f big
" Easily escape terminal mode
tnoremap <Esc> <C-\><C-n>
" Pressing shift semicolon was too long:
nnoremap <Space> :
" Fastest :w in the west
nnoremap <leader>w :w<CR>
" #---Visual Enhancements---# "
colorscheme friffle
" Remove latex underscore errors
let g:tex_no_error=1
" let g:airline_powerline_fonts = 1
" Lightline config
let g:lightline = {
      \ 'colorscheme': 'friffle',
      \ }
set noshowmode
" Vim-go breakpoints and debug
nnoremap mp :GoDebugBreakpoint<CR>
nnoremap mn :GoDebugNext<CR>
nnoremap ms :GoDebugStart<CR>
nnoremap mq :GoDebugStop<CR>

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
" NERDTRee Hotkey map
map <C-n> :NERDTreeToggle<CR>
    let NERDTreeDirArrowExpandable="|"
    let NERDTreeDirArrowCollapsible="-"
" Close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Other NERDTree Preferences
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowBookmarks=1
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeQuitOnOpen = 1
" Nvim-R send line
nmap <C-Enter> <leader>l
" Nvim folding
    let r_syntax_folding = 1
    set foldnestmax=1


" #---Universal Macros---# "
" Create and navigate Markers
" inoremap ;m <++>
inoremap ;; <Esc>/<++><CR>"_c4l
inoremap << «
inoremap >> »
" #---Filetype Specific Settings---# "
