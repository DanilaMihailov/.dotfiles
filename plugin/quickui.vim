" Section: Quickmenu

" clear all the menus
call quickui#menu#reset()

" install a 'File' menu, use [text, command] to represent an item.
call quickui#menu#install('&File', [
            \ [ "&Open...", "Telescope find_files", "Telescope all files" ],
            \ [ "&Explore\tCtrl-f", "Telescope file_browser", "Telescope file browser" ],
            \ [ "&Welcome screen\t:Startify", "Startify", "Show startify" ],
			\ [ '--','' ],
			\ [ "&Save as\t:saveas", "call feedkeys(':saveas ')", "Safe file with new name" ],
			\ [ '--','' ],
			\ [ "&Preferences", "tabe ~/.dotfiles/init.lua", "Edit init.lua" ],
			\ [ "&Reload vimrc", "silent! call ReloadConfig()", "source ~/.config/nvim/init.lua" ],
			\ [ '--','' ],
			\ [ "&Quit\t:qa", "qa", "Quit vim" ],
            \ ])

call quickui#menu#install("&Edit", [
            \ [ "&Format file\t:SPC f", "normal 1  f", "Format file using Coc" ],
            \ [ "Fo&ld\t:Fold", "Fold", "Fold file using Coc" ],
            \ [ "&Organize imports\t:OR", "OR", "Organize imports file using Coc" ],
			\ [ '--','' ],
            \ [ "Rewrap document\tgggqG", "norm gggqG", "Runs gggqG" ],
			\ [ '--','' ],
            \ [ "&Expand all folds\tzR", "norm zR", "Epands all folds" ],
            \ [ "&Collapse all folds\tzM", "norm zM", "Collapse all folds" ],
            \ ])

call quickui#menu#install("&Buffers", [
            \ [ "L&ist\tCtrl-b", "Telescope buffers", "Buffers" ],
			\ ['--',''],
            \ [ "Close &other buffers\t:Bdelete other", "Bdelete other", "" ],
            \ [ "Close hidd&en buffers\t:Bdelete hidden", "Bdelete hidden", "" ],
            \ [ "Close &this buffer\t:Bdelete this", "Bdelete this", "" ],
            \ [ "Close &nameless buffers\t:Bdelete nameless", "Bdelete nameless", "" ],
            \ ])
call quickui#menu#install("&Windows", [
            \ [ "&Zoom window\tSpace+-", "normal 1 -", "" ],
            \ [ "&Re-balance windows\tSpace+=", "normal 1 =", "" ],
			\ ['--',''],
            \ [ "Move to the left\tCtrl-w H", "wincmd H", "" ],
            \ [ "Move to the right\tCtrl-w L", "wincmd L", "" ],
            \ [ "Move to the bottom\tCtrl-w J", "wincmd J", "" ],
            \ [ "Move to the top\tCtrl-w K", "wincmd K", "" ],
			\ ['--',''],
            \ [ "&New window\tCtrl-w n", "wincmd n", "" ],
            \ [ "New tab\t:tabnew", "tabnew", "" ],
			\ ['--',''],
            \ [ "&Exchange windows\tCtrl-w x", "wincmd x", "" ],
            \ [ "&Move to tab\tCtrl-w T", "wincmd T", "" ],
			\ ['--',''],
            \ [ "Close other &tabs\t:tabo", "tabo", "" ],
            \ [ "Close other &windows\t<Ctrl-w> o", "wincmd o", "" ],
            \ ])
call quickui#menu#install("&Commands", [
            \ [ "&Search Commands\tSpace-p", "Telescope commands", "Commands" ],
            \ [ "Key &maps", "Telescope keymaps", "Telescope key maps" ],
			\ ['--',''],
            \ [ "&Save session", "SessionManager save_current_session", "" ],
            \ [ "L&oad last session", "SessionManager load_current_dir_session", "" ],
            \ [ "&Choose session", "SessionManager load_session", "" ],
            \ [ "&Delete session", "SessionManager delete_session", "" ],
			\ ['--',''],
            \ [ "Floating &Terminal\tCtrl-x Ctrl-t", "FloatermToggle", "FloatermToggle" ],
            \ ])

call quickui#menu#install("&Git", [
            \ [ "&Status\t:G", "G", "Git fugitive" ],
            \ [ "P&ull\t:Git pull", "Git pull", "Git pull" ],
            \ [ "&Push\t:Git push", "Git push", "Git push" ],
            \ [ "&Integrate\t:Git pull origin master --rebase", "Git pull origin master --rebase", "Git pull origin master --rebase" ],
			\ ['--',''],
            \ [ "&Open Files\tCtrl-p", "Telescope git_files", "Search git files" ],
            \ [ "Changed &Files", "Telescope git_status", "Git status files" ],
			\ ['--',''],
            \ [ "Create &branch", "call feedkeys(':Git checkout -b ')", "" ],
            \ [ "&Checkout branch", "Telescope git_branches", "Show list of branches" ],
            \ [ "Set upstream branch", "execute 'Git push origin -u '.fugitive#Head()", "Git push" ],
			\ ['--',''],
            \ [ "&Write and Commit", "call feedkeys(':Gwrite\<cr>:Gcommit\<cr>')", "Git write and then commit" ],
            \ [ "Co&mmit\t:Gcommit", "Gcommit", "Git commit" ],
			\ ['--',''],
            \ [ "Blame\t:Gblame", "Git blame", "Git blame" ],
            \ [ "Commits", "Telescope git_commits", "Git commits with telescope" ],
            \ ])

" script inside %{...} will be evaluated and expanded in the string
call quickui#menu#install("&Option", [
			\ ["Set &Spell \t%{&spell? 'Off':'On'}", 'set spell!', 'Enable spell checking'],
			\ ["Set L&ist \t%{&list? 'Off':'On'}", 'set list!', 'Show hidden characters'],
			\ ["Set &Wrap \t%{&wrap? 'Off':'On'}", 'set wrap!', 'Wrap lines'],
			\ ["Set &Background \t%{&background == 'dark' ? 'Light':'Dark'}", 'call ToggleBackground()', 'Change background'],
			\ ['--',''],
            \ [ "List &all\t:options", "vert options", ":options" ],
			\ ])

" register HELP menu with weight 10000
call quickui#menu#install('Hel&p', [
			\ ["&Search help\t:helpgrep", 'call feedkeys(":helpgrep ")', ''],
			\ ['--',''],
			\ ["&Cheatsheet\t:help index", 'vert help index', ''],
			\ ["T&ips\t:help tips", 'vert help tips', ''],
			\ ['--',''],
			\ ["&Tutorial\t:help tutor", 'vert help tutor', ''],
			\ ["&Quick Reference\t:help quickref", 'vert help quickref', ''],
			\ ['--',''],
			\ ["&Randow Tip\t:RandomVimTip", ':RandomVimTip', 'show random Vim Wiki Tip'],
			\ ], 10000)

function! ReloadConfig()
    source ~/.config/nvim/init.lua
    echo "vimrc reloaded"
endfunction

function! ToggleBackground()
    if &background == "dark"
        set background=light
        call QuickThemeChange("gruvbox light")
    else
        set background=dark
        call QuickThemeChange("gruvbox")
    endif
endfunction

let content = [
            \ ["Re&name\t<space>rn", 'normal 1 rn' ],
            \ ["&Actions\t<space>ca", 'normal 1 ca' ],
            \ ["&Quick fix\t<space>qf", 'normal 1 qf' ],
            \ ['-'],
            \ ["&Go to Defintion\tgd", 'normal gd' ],
            \ ["Show &References\t<space>gr", 'normal 1 gr'],
            \ ["Show &Implementation\t<space>gi", 'normal 1 gi'],
            \ ["Show T&ype Defintion\t<space>gy", 'normal 1 gy'],
            \ ['-'],
            \ ["&Translate", 'TranslateW'],
            \ ["&Find in Project", 'exec "silent! grep " . expand("<cword>") | copen' ],
            \ ['-'],
            \ ["&Documentation\tK", 'normal K' ],
            \ ["&Helpfull version", 'exec "HelpfulVersion ".expand("<cword>")', '', 'vim' ],
            \ ]

" set cursor to the last position
let opts = {'index':g:quickui#context#cursor}

nmap <C-k> :call quickui#tools#clever_context('k', content, opts)<CR>
vmap <C-k> :call quickui#tools#clever_context('k', content, opts)<CR>

let g:quickui_color_scheme = 'gruvbox'
let g:quickui_border_style = 2

" enable to display tips in the cmdline
let g:quickui_show_tip = 1

" hit space twice to open menu
noremap <leader>m :call quickui#menu#open()<cr>
noremap <leader><leader> :call quickui#menu#open()<cr>
