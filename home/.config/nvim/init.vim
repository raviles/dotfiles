set nocompatible
set number
set expandtab
set sw=4
set sts=4
set mouse=n
set nostartofline "stay in current column
set showmatch " show matching brackets
set cursorline

hi CursorLine   cterm=NONE ctermbg=darkgray ctermfg=NONE guibg=gray20 guifg=NONE
set backspace=indent,eol,start      "Allow backspace in insert mode
set history=1000                    "Store lots of :cmdline history
set noshowmode                      "Do not show current mode down the bottom
set visualbell                      "No sounds
set novb                            "No visualbell
set scrolloff=3
set fileformat=unix

set wildignore=*.o,*.pyc,*.obj,*.bak,*.exe
set wildignore+=*/node_modules/,*/.git,*/build,*/out,*/target
set wildchar=<Tab> wildmenu wildmode=full
set ignorecase
set smartcase

noremap <C-K> <C-Y> " scroll up, maintaning positionc
noremap <C-J> <C-E> " scroll down

" set wrap mode for h,l, and arrow keys
set whichwrap=h,l

set nohlsearch " do not highlight searched for phrases
set incsearch " highlight as you type you search phrase

set backup
set backupdir=~/.vim/backup

" Where temp files are located 
set directory=~/.vim/tmp


function! SetupNVimTree()
lua <<EOF

require("nvim-web-devicons").setup({
 -- your personnal icons can go here (to override)
 -- you can specify color or cterm_color instead of specifying both of them
 -- DevIcon will be appended to `name`
 override = {
  zsh = {
    icon = "",
    color = "#428850",
    cterm_color = "65",
    name = "Zsh"
  }
 };
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
})

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  respect_buf_cwd = true,
  -- sync_root_with_cwd = true,
  git = {
      enable = true,
      ignore = false
  },
  view = {
    adaptive_size = false,
    width = 40
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
    root_folder_modifier = ":t",
  },
  filters = {
    dotfiles = false,
    custom = { "^.git$"}
  },
  actions = {
    expand_all = {
        exclude = {".git", "build", "out"}
    },
  },

  on_attach = function(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Default key mappings
    api.config.mappings.default_on_attach(bufnr)

    -- Override <Tab> to toggle back to previous window
    vim.keymap.set("n", "<Tab>", function()
      vim.cmd("wincmd p")
    end, opts("Toggle back to previous window"))
  end,
})


EOF
endfunction

function! SetupDiffView()
lua <<EOF

local actions = require("diffview.actions")

require("diffview").setup({})

EOF
endfunction


function! SetupToggleTerm()
lua <<EOF


local first_open = true
require("toggleterm").setup({
    open_mapping = [[<c-\>]],
    direction = 'float',
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    persist_mode = true,
    close_on_exit = false, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    float_opts = {
        border = 'curved',
        width = 200,
        height = 100,
        row=2,
        col=41

    },
    on_create = function(term)
      vim.defer_fn(function()
        -- Sends the command to the terminal as if typed
        term:send("source ~/.profile", false)
      end, 50) -- short delay to ensure terminal is ready
    end,
})


EOF
endfunction

call plug#begin()

    Plug 'udalov/kotlin-vim'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
    Plug 'EdenEast/nightfox.nvim'
    Plug 'kyazdani42/nvim-tree.lua'
    Plug 'romgrk/barbar.nvim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'akinsho/toggleterm.nvim', {'tag' : 'v2.*'}

    Plug 'nvim-lua/plenary.nvim'
    Plug 'sindrets/diffview.nvim'

call plug#end()

call SetupNVimTree()
call SetupToggleTerm()

let g:fzf_layout = { 'window': { 'width': 0.90, 'height': 0.90, 'row': 0, 'col': 0, 'border': 'rounded' } }

let bufferline = get(g:, 'bufferline', {})
let bufferline.animation = v:false
let bufferline.no_name_title = "Untitled"
let bufferline.maximum_padding = 0


lua <<EOF
require('barbar').setup {
  icons = {
    filetype = {
      enabled = false,
    },
  },
}

local bufferline_state = require('bufferline.state')
local api = require("nvim-tree.api")

api.events.subscribe(api.events.Event.TreeOpen, function()
  bufferline_state.set_offset(40, "File Tree")
end)

api.events.subscribe(api.events.Event.TreeClose, function()
  bufferline_state.set_offset(0)
end)

EOF


function! ToggleFocus()
lua << EOF
local view = require("nvim-tree.view")
if view.is_visible() then
  if vim.fn.winnr() == vim.fn.bufwinnr(view.get_bufnr()) then
    vim.cmd("wincmd p")  -- go back to previous window
  else
    vim.cmd("NvimTreeFocus")
  end
else
  vim.cmd("NvimTreeOpen")
end
EOF
endfunction

function! ToggleDiffView()
    let a = winnr()
    if a == 1
        DiffviewClose
    else
        DiffviewOpen
    endif

endfunction


function! RunAOSPBuild()
    execute "w"
    TermExec cmd="clear && cd `dirname %:p` && ~/projects/tools/build-and-run.sh"
endfunction


function! VisualSelection()
    if mode()=="v"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    end
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
            return ''
    endif
    let lines[-1] = lines[-1][: column_end - 1]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction


function! Do() 

    let v = VisualSelection()
    echo v


endfunction

nnoremap , :qa<CR>
nnoremap <silent>    <C-h> <Cmd>BufferPrevious<CR>
nnoremap <silent>    <C-l> <Cmd>BufferNext<CR>
nnoremap <silent>    <S-h> <Cmd>BufferMovePrevious<CR>
nnoremap <silent>    <S-l> <Cmd>BufferMoveNext<CR>
noremap <silent>    <C-W> <Cmd>BufferClose<CR>
"nnoremap <silent>    <> <Cmd>BufferCloseAllButPinned<CR>
"
noremap <silent>    <C-f> <Cmd>NvimTreeFindFile<CR>

noremap <silent>    <C-o> <Cmd>Files<CR>

nnoremap <silent>    <C-s> :w<CR>
nnoremap <silent>    <S-s> :w<CR>
nnoremap <silent>    <C-N> :set invnumber<CR>
noremap <silent>    <C-j> <C-e>
noremap <silent>    <C-k> <C-y>

nnoremap <silent>    <C-]> :call RunAOSPBuild()<CR>
nnoremap <silent>    <S-D> :call ToggleDiffView()<CR>

nnoremap <silent>    ` :call ToggleFocus()<CR>
nnoremap <silent>    <tab> :call ToggleFocus()<CR>
vnoremap <silent>    <S-T> :call Do()<CR>

highlight StatusLineNC cterm=bold ctermfg=white ctermbg=darkgray

"colorscheme nightfox
"
autocmd VimEnter * NvimTreeOpen

