set nocompatible


filetype on
filetype plugin on
set ofu=syntaxcomplete#Complete
set fileformat=unix
"set autoindent
set history=1000 " How many lines of history to remember
set wildignore=*.o,*.pyc,*.obj,*.bak,*.exe
set hidden " ignore changed-errors when moving buffers
set iskeyword+=_,$,@,%,- " none of these should be word dividers, so make them not be
set clipboard+=unnamed
syntax on
set noequalalways " don't resize windows after saving from ftp, among other things
set wildchar=<Tab> wildmenu wildmode=full
set ignorecase
set smartcase

" show line numbers, use C-N to invert
set number
map <C-N> :set invnumber<CR>

set cursorline
colorscheme darkspectrum
hi CursorLine   cterm=NONE ctermbg=darkgray ctermfg=NONE guibg=#333333 guifg=NONE

" make 2 status lines, set first to full file path
set laststatus=1
"set statusline+=%F

" http://www.renownedmedia.com/blog/installing-vim-tagbar-with-macvim-in-os-x/
let Tlist_Ctags_Cmd='/usr/local/bin/ctags'
let Tlist_Use_Right_Window=1
let Tlist_WinWidth = 40
map <silent> <F3> :TlistToggle<CR>:wincmd l<CR><C-c>

"""""""""""""""""""""""""""""""""""""""""""
" Scrolling
set scrolloff=3 " display a minimum number of lines when scrolling
noremap <Space> <PageDown>
noremap <C-K> <C-Y> " scroll up, maintaning positionc
noremap <C-J> <C-E> " scroll down
"""""""""""""""""""""""""""""""""""""""""""

set nofoldenable
set textwidth=0 " dont insert EOL automatically, at any wrap margin

" tabs
set expandtab
set sw=4
set sts=4

set nostartofline "stay in current column
set showmatch " show matching brackets


" set wrap mode for h,l, and arrow keys
set whichwrap=h,l

	
"""""""""""""""""""""""""""""""""""""""""""
map <C-G> :!git diff %&<CR><CR>

"""""""""""""""""""""""""""""""""""""""""""
" IndentGuides
" vim-indent-guides https://github.com/nathanaelkane/vim-indent-guides
"let g:indent_guides_start_level=2
"let g:indent_guides_guide_size=1
"map <silent> <C-i> :IndentGuidesToggle<CR>
"""""""""""""""""""""""""""""""""""""""""""

" backspacing
noremap <BS> i<BS>  " emulate a backspace in command mode
imap <C-BS> <Esc>dbxi " control-backspace deletes previous word
set backspace=eol,start,indent


"""""""""""""""""""""""""""""""""""""""""""
" Searching
set nohlsearch " do not highlight searched for phrases
set incsearch " highlight as you type you search phrase
vmap g/ y/<C-R>"<CR>
" Search highlighted text
" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
"""""""""""""""""""""""""""""""""""""""""""

map <END> <ESC>


set backup
if empty(glob('~/.vim/backup'))
    silent !mkdir -p ~/.vim/backup
endif
set backupdir=~/.vim/backup

" Where temp files are located 
if empty(glob('~/.vim/tmp'))
    silent !mkdir -p ~/.vim/tmp
endif
set directory=~/.vim/tmp

execute pathogen#infect()

"hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan
"
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR> 

map <C-h> <Plug>(wintabs_previous)
map <C-l> <Plug>(wintabs_next)
"map <C-S-w> <Plug>(wintabs_close)
command! Tabc WintabsCloseVimtab
command! Tabo WintabsOnlyVimtab

au VimEnter * call wintabs#all_buffers()

augroup DiffWrap
  autocmd!
  autocmd VimEnter * if &diff | execute 'windo setlocal wrap' | endif
  autocmd BufEnter * if &diff | setlocal wrap | endif
augroup END

" Close all buffers except current
"   %bd|e#
"
nnoremap , :qa<CR>
"noremap < :bd<Cr>

if &diff 
    setlocal noro modifiable 
endif


" ── Diff-mode convenience ────────────────────────────────────────────────────
" <C-e>: toggle diff folds (zR/zM) when in diff; otherwise keep default scroll-down.
" <C-n>: go to next change (]c) when in diff; otherwise keep default behavior.
nnoremap <expr> <C-e> &diff ? (&foldlevel == 0 ? 'zR' : 'zM') : "\<C-e>"
nnoremap <expr> <C-n> &diff ? ']c' : "\<C-n>"
