" fish has issues so let's use zsh
set shell=zsh

" Run pathogen
execute pathogen#infect()
syntax on
filetype plugin indent on

" Make sure color is being used
if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
	set t_Co=256
endif

" The colorscheme
" colorscheme coffee
" colorscheme molokai
let g:zenburn_transparent=1
colorscheme zenburn
" Override the black background so we can see the iTerm2 background image
hi Normal guibg=NONE ctermbg=NONE

" Airline config
set laststatus=2
let g:Powerline_symbols = 'unicode'
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

" Set the tab width
set expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Mappings
set statusline=%{fugitive#statusline()}
set backspace=indent,eol,start
let mapleader = "\<Space>"
nmap \l :setlocal number!<CR>
nmap \o :set paste!<CR>
nmap j gj
nmap k gk
nmap ., :grep -Rin --exclude \*/migrations/\* --include \*.py 
nmap .c :grep -Rin --include \*.coffee 
nmap .h :grep -Rin --exclude \*/site-packages/\* --include \*.html 
nmap .s :grep -Rin --include \*.scss 
cnoremap <C-a>  <Home>
cnoremap <C-b>  <Left>
cnoremap <C-f>  <Right>
cnoremap <C-d>  <Delete>
cnoremap <M-b>  <S-Left>
cnoremap <M-f>  <S-Right>
cnoremap <M-d>  <S-right><Delete>
cnoremap <Esc>b <S-Left>
cnoremap <Esc>f <S-Right>
cnoremap <Esc>d <S-right><Delete>
cnoremap <C-g>  <C-c>
set incsearch
set ignorecase
set smartcase
set hlsearch
nmap \q :nohlsearch<CR>
nmap <C-e> :e#<CR>
nmap <C-n> :bnext<CR>
nmap <C-p> :bprev<CR>
let g:ctrlp_map = '<Leader>t'
let g:ctrlp_match_window_bottom = 0
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_dotfiles = 0
let g:ctrlp_switch_buffer = 0
nmap \e :NERDTreeToggle<CR>
nmap \t :set expandtab tabstop=4 shiftwidth=4 softtabstop=4<CR>
nmap \T :set expandtab tabstop=8 shiftwidth=8 softtabstop=4<CR>
nmap \M :set noexpandtab tabstop=8 softtabstop=4 shiftwidth=4<CR>
nmap \m :set expandtab tabstop=2 shiftwidth=2 softtabstop=2<CR>
nmap \w :setlocal wrap!<CR>:setlocal wrap?<CR>
nmap ; :CtrlPBuffer<CR>
nmap <C-N> :cnext<CR>
nmap <C-P> :cprev<CR>
set wildignore+=**/*.build.*,*.swp,*/node_modules/*,*/migrations/*,*/site-packages/*

" Move a line up or down
function! s:swap_lines(n1, n2)
    let line1 = getline(a:n1)
    let line2 = getline(a:n2)
    call setline(a:n1, line2)
    call setline(a:n2, line1)
endfunction

function! s:swap_up()
    let n = line('.')
    if n == 1
        return
    endif

    call s:swap_lines(n, n - 1)
    exec n - 1
endfunction

function! s:swap_down()
    let n = line('.')
    if n == line('$')
        return
    endif

    call s:swap_lines(n, n + 1)
    exec n + 1
endfunction

noremap <silent> <C-j> :call <SID>swap_up()<CR>
noremap <silent> <C-k> :call <SID>swap_down()<CR>

" Insert the current date
nnoremap <F5> "=strftime("%m-%d-%Y")<CR>p
inoremap <F5> <C-R>=strftime("%m-%d-%Y")<CR>

