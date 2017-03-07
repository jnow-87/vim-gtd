if exists('g:loaded_gtd') || &compatible
	finish
endif

let g:loaded_gtd = 1

" get own script ID
nmap <c-f11><c-f12><c-f13> <sid>
let s:sid = "<SNR>" . maparg("<c-f11><c-f12><c-f13>", "n", 0, 1).sid . "_"
nunmap <c-f11><c-f12><c-f13>


""""
"" global variables
""""
"{{{
"{{{
" symbol window settings
let g:gtd_sym_window_title				= get(g:, "gtd_sym_window_title", "gtd")
let g:gtd_sym_window_width				= get(g:, "gtd_sym_window_width", "40")
let g:gtd_sym_preview_width				= get(g:, "gtd_sym_preview_width", "40")

let g:gtd_sym_window_show_signature		= get(g:, "gtd_sym_window_show_signature", 1)
let g:gtd_sym_window_foldopen			= get(g:, "gtd_sym_window_foldopen", 0)

let g:gtd_sym_window_kinds_C			= get(g:, "gtd_sym_window_kinds_c", ['c', 'd', 'f', 'g', 'l', 'p', 's', 't', 'u', 'v', 'x'])
let g:gtd_sym_window_kinds_Asm			= get(g:, "gtd_sym_window_kinds_asm", ['d', 'l', 'm', 't'])
let g:gtd_sym_window_kinds_Vim			= get(g:, "gtd_sym_window_kinds_vim", ['a', 'c', 'f', 'm', 'v'])
let g:gtd_sym_window_kinds_Sh			= get(g:, "gtd_sym_window_kinds_sh", ['f'])
let g:gtd_sym_window_kinds_Make			= get(g:, "gtd_sym_window_kinds_make", ['m'])
let g:gtd_sym_window_kinds_Python		= get(g:, "gtd_sym_window_kinds_python", ['c', 'f', 'm', 'v', 'i'])
let g:gtd_sym_window_kinds_Java			= get(g:, "gtd_sym_window_kinds_java", ['c', 'e', 'f', 'g', 'i', 'l', 'm', 'p'])
"}}}

"{{{
" symbol list settings
let g:gtd_sym_list_kinds_C				= get(g:, "gtd_sym_list_kinds_c", ['c', 'd', 'f', 'g', 'l', 'p', 's', 't', 'u', 'v', 'x'])
let g:gtd_sym_list_kinds_Asm			= get(g:, "gtd_sym_list_kinds_asm", ['d', 'l', 'm', 't'])
let g:gtd_sym_list_kinds_Vim			= get(g:, "gtd_sym_list_kinds_vim", ['a', 'c', 'f', 'm', 'v'])
let g:gtd_sym_list_kinds_Sh				= get(g:, "gtd_sym_list_kinds_sh", ['f'])
let g:gtd_sym_list_kinds_Make			= get(g:, "gtd_sym_list_kinds_make", ['m'])
let g:gtd_sym_list_kinds_Python			= get(g:, "gtd_sym_list_kinds_python", ['c', 'f', 'm', 'v', 'i'])
let g:gtd_sym_list_kinds_Java			= get(g:, "gtd_sym_list_kinds_java", ['c', 'e', 'f', 'g', 'i', 'l', 'm', 'p'])

let g:gtd_sym_list_show_signature		= get(g:, "gtd_sym_list_show_signature", 0)

let g:gtd_sym_menu						= get(g:, "gtd_sym_menu", "» ")
"}}}

"{{{
" available mappings
let g:gtd_map_def_split			= get(g:, "gtd_map_def_split", "lf")
let g:gtd_map_def_tab			= get(g:, "gtd_map_def_tab", "tf")
let g:gtd_map_decl_split		= get(g:, "gtd_map_decl_split", "lp")
let g:gtd_map_decl_tab			= get(g:, "gtd_map_decl_tab", "tp")

let g:gtd_map_def_split_glob	= get(g:, "gtd_map_def_split_glob", "glf")
let g:gtd_map_def_tab_glob		= get(g:, "gtd_map_def_tab_glob", "gtf")
let g:gtd_map_decl_split_glob	= get(g:, "gtd_map_decl_split_glob", "glp")
let g:gtd_map_decl_tab_glob		= get(g:, "gtd_map_decl_tab_glob", "gtp")

let g:gtd_map_head_list			= get(g:, "gtd_map_head_list", "lh")
let g:gtd_map_head_focus		= get(g:, "gtd_map_head_focus", "th")

let g:gtd_map_opt_menu			= get(g:, "gtd_map_opt_menu", "lm")
let g:gtd_map_sym_menu_loc		= get(g:, "gtd_map_sym_menu_loc", "ls")

let g:gtd_map_quit				= get(g:, "gtd_map_quit", "q")
let g:gtd_map_expand			= get(g:, "gtd_map_expand", "x")
let g:gtd_map_select			= get(g:, "gtd_map_select", "<cr>")
let g:gtd_map_update_win		= get(g:, "gtd_map_update_win", "u")
let g:gtd_map_update_sym		= get(g:, "gtd_map_update_sym", "U")
"}}}

let g:gtd_symtab_initialised	= 0
"}}}

""""
"" highlighting config
""""
"{{{
highlight default gtd_select	ctermfg=255 ctermbg=31
highlight default gtd_filename	ctermfg=255 ctermbg=244
highlight default gtd_kind		ctermfg=27
highlight default gtd_comment	ctermfg=27
"}}}

""""
"" local variables
""""
"{{{
"{{{
" option menu entries
let s:opt = [
	\ {"abbr": g:gtd_sym_menu . "goto definition (split)", "menu": g:gtd_map_def_split},
	\ {"abbr": g:gtd_sym_menu . "goto defintion (tab)", "menu": g:gtd_map_def_tab},
	\ {"abbr": g:gtd_sym_menu . "goto declaration (split)", "menu": g:gtd_map_decl_split},
	\ {"abbr": g:gtd_sym_menu . "goto declaration (tab)", "menu": g:gtd_map_decl_tab},
	\ {"abbr": g:gtd_sym_menu . "list function head", "menu": g:gtd_map_head_list},
	\ {"abbr": g:gtd_sym_menu . "focus function head", "menu": g:gtd_map_head_focus},
\ ]
"}}}

let s:goto_mode = ""
let s:sym_window_line = 0
let s:sym_window_line_map = []
"}}}

""""
"" local functions
""""
"{{{
" \brief	menu selection handler for symbol menu
" 			moves to file:line of selected symbol
"
" \param	selection	selected menu entry
function s:sym_selected(selection)
	" check if selection is valid
	if len(a:selection) && a:selection.menu != ""
		let [file, line] = split(a:selection.menu, ':')

		" move to selected symbol
		call s:sym_focus(file, line)
	endif
endfunction
"}}}

"{{{
" \brief	menu selection handler for option menu
" 			triggers selected action
"
" \param	selection	selected menu entry
function s:opt_selected(selection)
	" check if selection is valid
	if len(a:selection) && a:selection.menu != ""
		" trigger action through available mappings
		exec "call feedkeys(\"" . a:selection.menu . "\")"
	endif
endfunction
"}}}

"{{{
" \brief	move to given file and line
"
" \param	file	file to focus
" \param	line	line to focus
function s:sym_focus(file, line)
	" ensure to be out of insert mode
	call feedkeys("\<esc>")

	if s:goto_mode == "t"
		" check for file in open tabs or open a new one
		call util#window#focus_file(a:file, a:line, 1)

	else
		" open file in split window
		exec "rightbelow " . g:gtd_sym_preview_width . "vsplit " . a:file

		" set temporary mappings
		call util#map#n(g:gtd_map_quit, ":call " . s:sid . "split_close()<cr>", "<buffer>")
		call util#map#n(g:gtd_map_expand, ":call util#window#expand()<cr>", "<buffer>")

		" autocmd to cleanup temporary mappings once leaving the buffers window
		autocmd WinLeave <buffer> silent call s:split_close()

		" goto line
		exec a:line

		" open potential folds
		silent! foldopen
	endif
endfunction
"}}}

"{{{
" \brief	cleanup preview split window
function s:split_close()
	" remove autocmds
	autocmd! WinLeave <buffer>

	" remove mappings
	exec "nunmap <buffer> " . g:gtd_map_quit
	exec "nunmap <buffer> " . g:gtd_map_expand

	" close the window
	silent! close
endfunction
"}}}

"{{{
" \brief	add a line to the symbol window
"
" \param	s		string to add
" \param	map_e	dictionary used for <cr> mapping to move to symbol
" 					dictionary keys:
" 						"file"
" 						"line"
function s:sym_buf_add_line(s, map_e)
	" add string to buffer
	call append(s:sym_window_line, a:s)

	" add dictionary to 'per-line' list
	let s:sym_window_line_map += [a:map_e]

	" increment line number
	let s:sym_window_line += 1
endfunction
"}}}

"{{{
" \brief	trigger symbol table update
"
" \param	force_all	0: perform update for current buffer
" 						else: perform update for all open buffers
function s:update(force_all)
	" only perform update if the user triggered symtab initialisation (either
	" through opening the symbol window or using any of the mappings)
	if g:gtd_symtab_initialised > 0
		if a:force_all
			" perform update for all open buffers
			call gtd#symtab#update_openbufs()

		elseif &filetype == "c" || &filetype == "cpp" || &filetype == "asm" || &filetype == "vim" || &filetype == "sh" || &filetype == "make" || &filetype == "python" || &filetype == "java"
			" perform update for current buffer if it filetype is considered
			call gtd#symtab#update_buf(bufname('%'))
		endif

		" update the symbol window buffer
		call s:sym_window_update()
	endif
endfunction
"}}}

"{{{
" \brief	select a line within the symbol window
" 			move to respective symbol if possible
function s:sym_window_select()
	let line = line('.') - 1

	" check if a symbol is available for current line
	if line < s:sym_window_line && len(s:sym_window_line_map[line]) == 2
		" highlight selected line in make buffer
		match none
		exec 'match gtd_select /\%' . line('.') . 'l[^ \t].*/'

		" move to symbol
		call util#window#focus_file(s:sym_window_line_map[line].file, s:sym_window_line_map[line].line, 1)
	endif
endfunction
"}}}

"{{{
function s:list_add(lst, dict, key)
	let i = 0
	for e in a:lst
		if e[a:key] >= a:dict[a:key]
			break
		endif

		let i += 1
	endfor

	call insert(a:lst, a:dict, i)
endfunction
"}}}

""""
"" global functions
""""
"{{{
" \brief	open options menu
"
" \return	'<c-r>=' string, triggering auto completion
function s:opt_menu()
	return util#pmenu#open(s:opt, s:sid . "opt_selected", "i")
endfunction
"}}}

"{{{
" \brief	open menu with buffer-local symbols
"
" \return	'<c-r>=' string, triggering auto completion
function s:sym_menu()
	let lst = []

	" get symtab for current buffer
	let symtab = gtd#symtab#get(bufname("%"))

	" iterate through all considered kinds
	for kind in g:gtd_sym_list_kinds_{symtab.lang}
		if !has_key(symtab["kinds"], kind)
			continue
		endif

		" generate menu list
		for [sym, sym_lst] in items(symtab["kinds"][kind])
			for entry in sym_lst
				call s:list_add(lst, {
					\ "menu": entry.file . ":" . entry.line,
					\ "kind": kind,
					\ "abbr": (g:gtd_sym_list_show_signature ? entry.signature : sym)
					\ }, "abbr")
			endfor
		endfor
	endfor

	" force new tab on symbol selection
	let s:goto_mode = "t"

	" open menu
	return util#pmenu#open(lst, s:sid . "sym_selected", "i")
endfunction
"}}}

"{{{
" \brief	perform symbol lookup
"
" \param	kind	kind to look for
" 					cf. gtd#symtab#lookup()
" \param	flags	flags for lookup and result handling
" 					't': open respective file in new buffer if it is not the current buffer
" 					's': open respective file in split window
" 					cf. gtd#symtab#lookup()
"
" \return	'<c-r>=' string, triggering auto completion
function s:sym_lookup(kind, flags)
	" perform symbol lookup
	let syms = gtd#symtab#lookup(expand('<cword>'), bufname('%'), a:kind, a:flags)
	let len = len(syms)

	" set reaction
	let s:goto_mode = (stridx(a:flags, "t") != -1) ? "t" : "s"

	" check number of symbols found
	if len == 1
		" show symbol if its the only one
		call s:sym_focus(syms[0].file, syms[0].line)

	elseif len > 1
		" generate menu containing all found symbols
		let menu = []

		for e in syms
			call s:list_add(menu, {"abbr": e.signature, "menu": e.file . ":" . e.line . " ", "kind": e.kind }, "menu")
		endfor

		" show menu
		return util#pmenu#open(menu, s:sid . "sym_selected", "i")
	endif

	return ""
endfunction
"}}}

"{{{
" \brief	show or focus current function
"
" \param	flags	'l': print current function signature in status line
" 					't': move to current function head
function s:fct_head(flags)
	" get symtab for current file
	let symtab = gtd#symtab#get(bufname("%"))

	let rval = { "line": 0}

	" iterate through symbols
	for val_lst in values(symtab["syms"])
		for val in val_lst
			" check if current symbol is a function defintion that is above current line and below last match
			if gtd#symtab#longname(symtab.lang, "func_kind") == val.kind && str2nr(val.line) > str2nr(rval.line) && str2nr(val.line) <= line('.')
				let rval = val
			endif
		endfor
	endfor

	if rval.line != 0 && a:flags == "l"
		" print signature in status line
		echom rval.signature

	elseif rval.line != 0 && a:flags == "t"
		" focus respective line
		exec rval.line
		silent! foldopen
	endif
endfunction
"}}}

"{{{
" \brief	open/focus the symbol window
"
" \return	0: symbol window was already present
" 			1: symbol window needed to be opened
function s:sym_window_show()
	" try to focus symbol window, return on success
	if util#window#focus_window(bufwinnr("^" . g:gtd_sym_window_title . "$"), -1, 0) == 0
		return 0
	endif

	" open symbol window in split window
	exec "rightbelow " . g:gtd_sym_window_width . "vsplit"

	" load symbol window buffer
	exec "edit " . g:gtd_sym_window_title

	" configure the buffer
	set filetype=gtd
	setlocal noswapfile
	setlocal bufhidden=hide
	setlocal nowrap
	setlocal buftype=nofile
	setlocal nobuflisted
	setlocal colorcolumn=0
	setlocal winfixwidth
	setlocal foldnestmax=2
	setlocal foldmethod=syntax
	setlocal nomodifiable

	" buffer mappings
	call util#map#n(g:gtd_map_quit, ":close<cr>", "<buffer>")
	call util#map#n(g:gtd_map_select, ":call " . s:sid . "sym_window_select()<cr>", "<buffer>")
	call util#map#n(g:gtd_map_expand, ":call util#window#expand()<cr>", "<buffer>")
	call util#map#n(g:gtd_map_update_win, ":call " . s:sid . "sym_window_update()<cr>", "<buffer>")
	call util#map#n(g:gtd_map_update_sym, ":call " . s:sid . "update(1)<cr>", "<buffer>")

	return 1
endfunction
"}}}

"{{{
" \brief	toggle symbol window
" 			open if not opened
" 			focus if opened but not focused
" 			close if current buffer
function s:sym_window_toggle()
	if bufwinnr("^" . g:gtd_sym_window_title . "$") == winnr()
		" close symbol window if currently focused
		close

	else
		" open symbol window
		if s:sym_window_show() != 0
			" if symbol window needed to be opened force an update
			call s:sym_window_update()
		endif
	endif
endfunction
"}}}

"{{{
" \brief	update symbol window
function s:sym_window_update()
	" ensure to focus symbol window
	let close_on_return = s:sym_window_show()
	
	" enable modification and clear buffer
	setlocal modifiable
	%delete

	let s:sym_window_line_map = []
	let s:sym_window_line = 0
	let cur_buf_line = 1

	" print help
	call s:sym_buf_add_line("\" " . g:gtd_map_update_win . ": update window", {})
	call s:sym_buf_add_line("\" " . g:gtd_map_update_sym . ": update symbol table", {})
	call s:sym_buf_add_line("\" " . g:gtd_map_quit . ": close window", {})
	call s:sym_buf_add_line("\" " . g:gtd_map_expand . ": expand window", {})
	call s:sym_buf_add_line("\" " . g:gtd_map_select . ": goto symbol under cursor", {})
	call s:sym_buf_add_line("", {})

	let bnum = 1

	" iterate through open buffers
	while bnum <= bufnr("$")
		let bname = bufname(bnum)
		let bnum += 1

		let symtab = gtd#symtab#get(bname)

		" ignore empty buffers and buffers without symtab
		if bname == "" || len(symtab) == 0
			continue
		endif

		" print buffer name
		call s:sym_buf_add_line("", {})
		call s:sym_buf_add_line(bname, {})

		" store line if the buffer name matches the alternate buffer
		" used to select this buffer once finished the update
		if bname == bufname('#')
			let cur_buf_line = s:sym_window_line
		endif

		" only print configured symbols kinds
		for kind in g:gtd_sym_window_kinds_{symtab.lang}
			if !has_key(symtab["kinds"], kind)
				continue
			endif

			" print kind longname
			call s:sym_buf_add_line("  " . gtd#symtab#longname(symtab.lang, kind), {})

			" generate sorted symbol list
			let lst = []

			for sym in keys(symtab["kinds"][kind])
				for entry in symtab["kinds"][kind][sym]
					" add to list, sort by symbol name (i.e. "key")
					call s:list_add(lst, {
						\ "dict": {"file": entry.file, "line": entry.line},
						\ "key": sym,
						\ "txt": "    " . (g:gtd_sym_window_show_signature ? entry.signature : sym)
						\ }, "key")
				endfor
			endfor

			" print symbols
			for e in lst
				call s:sym_buf_add_line(e.txt, e.dict)
			endfor

			let lst = []

			call s:sym_buf_add_line("", {})
		endfor
	endwhile

	" lock buffer
	setlocal nomodifiable

	" set syntax highlighting
	syntax match gtd_comment "^\".*$"
	syntax match gtd_filename "^[^ \"].*$"
	syntax match gtd_kind "^  [^ ].*$"

	syntax region gtd_file_body start="^  " end="^$" fold contains=gtd_filename,gtd_kind,gtd_kind_body

	" open folds if configured
	if g:gtd_sym_window_foldopen
	 	silent! 0,$foldopen
	endif

	" focus target line
	exec cur_buf_line

	" close symbol window if it needed to be opened only to perform the update
	if close_on_return == 1
		close
	endif
endfunction
"}}}

""""
"" commands
""""
"{{{
command -nargs=0 GtdSymtabPrint call gtd#symtab#print()
command -nargs=0 GtdSymWindowToggle silent call s:sym_window_toggle()
"}}}

""""
"" autocommands
""""
"{{{
" update symbol tables when writing a file
autocmd BufWritePost * silent call s:update(0)

" close make buffer if its the last in the current tab
exec 'autocmd BufEnter ' . g:gtd_sym_window_title . ' silent if winnr("$") == 1 | quit | endif'
"}}}

""""
"" mappings
""""
"{{{
call util#map#n(g:gtd_map_head_focus,		":call " . s:sid . "fct_head('t')<cr>", "")
call util#map#n(g:gtd_map_head_list,		":call " . s:sid . "fct_head('l')<cr>", "")

call util#map#n(g:gtd_map_decl_split,		"<insert><c-r>=" . s:sid . "sym_lookup('p', 'l')<cr>", "")
call util#map#n(g:gtd_map_decl_tab,			"<insert><c-r>=" . s:sid . "sym_lookup('p', 't')<cr>", "")
call util#map#n(g:gtd_map_def_split,		"<insert><c-r>=" . s:sid . "sym_lookup('f', 'l')<cr>", "")
call util#map#n(g:gtd_map_def_tab,			"<insert><c-r>=" . s:sid . "sym_lookup('f', 't')<cr>", "")

call util#map#n(g:gtd_map_decl_split_glob,	"<insert><c-r>=" . s:sid . "sym_lookup('p', 'gl')<cr>", "")
call util#map#n(g:gtd_map_decl_tab_glob,	"<insert><c-r>=" . s:sid . "sym_lookup('p', 'gt')<cr>", "")
call util#map#n(g:gtd_map_def_split_glob,	"<insert><c-r>=" . s:sid . "sym_lookup('f', 'gl')<cr>", "")
call util#map#n(g:gtd_map_def_tab_glob,		"<insert><c-r>=" . s:sid . "sym_lookup('f', 'gt')<cr>", "")

call util#map#n(g:gtd_map_opt_menu,			"<insert><c-r>=" . s:sid . "opt_menu()<cr>", "")
call util#map#n(g:gtd_map_sym_menu_loc,		"<insert><c-r>=" . s:sid . "sym_menu()<cr>", "")
"}}}
