" TODO
" 	- sort symbol lists
" 	- support other languages (vim, bash)

""""
"" initialisation
""""
"{{{
if exists('g:loaded_gtd') || &compatible
	finish
endif

let g:loaded_gtd = 1

" get own script ID
nmap <c-f11><c-f12><c-f13> <sid>
let s:sid = maparg("<c-f11><c-f12><c-f13>", "n", 0, 1).sid
nunmap <c-f11><c-f12><c-f13>
"}}}

""""
"" global variables
""""
"{{{
let g:gtd_key_def_split			= get(g:, "gtd_key_def_split", "pp")
let g:gtd_key_def_tab			= get(g:, "gtd_key_def_tab", "tp")
let g:gtd_key_decl_split		= get(g:, "gtd_key_decl_split", "pf")
let g:gtd_key_decl_tab			= get(g:, "gtd_key_decl_tab", "tf")

let g:gtd_key_def_split_glob	= get(g:, "gtd_key_def_split_glob", "gpp")
let g:gtd_key_def_tab_glob		= get(g:, "gtd_key_def_tab_glob", "gtp")
let g:gtd_key_decl_split_glob	= get(g:, "gtd_key_decl_split_glob", "gpf")
let g:gtd_key_decl_tab_glob		= get(g:, "gtd_key_decl_tab_glob", "gtf")

let g:gtd_key_head_list			= get(g:, "gtd_key_head_list", "lh")
let g:gtd_key_head_focus		= get(g:, "gtd_key_head_focus", "th")

let g:gtd_key_opt_menu			= get(g:, "gtd_key_menu", "lm")
let g:gtd_key_sym_menu_loc		= get(g:, "gtd_sym_menu", "ls")
let g:gtd_key_sym_menu_glob		= get(g:, "gtd_sym_menu", "gls")
"}}}

""""
"" local variables
""""
"{{{
let s:goto_mode = "s"

let s:opt = [
	\ {"abbr": "[def split]", "menu": g:gtd_key_def_split},
	\ {"abbr": "[def tab]", "menu": g:gtd_key_def_tab},
	\ {"abbr": "[decl split]", "menu": g:gtd_key_decl_split},
	\ {"abbr": "[decl tab]", "menu": g:gtd_key_decl_tab},
	\ {"abbr": "[list head]", "menu": g:gtd_key_head_list},
	\ {"abbr": "[focus head]", "menu": g:gtd_key_head_focus},
\ ]
"}}}

""""
"" helper functions
""""
"{{{
function s:sym_selected(selection)
	if len(a:selection) && a:selection.menu != ""
		let [file, line] = split(a:selection.menu, ':')

		let s:goto_mode = "t"
		call s:sym_focus(file, line)
	endif
endfunction
"}}}

"{{{
function s:opt_selected(selection)
	if len(a:selection) && a:selection.menu != ""
		exec "call feedkeys(\"" . a:selection.menu . "\")"
	endif
endfunction
"}}}

"{{{
function s:sym_focus(file, line)
	call feedkeys("\<esc>")

	if s:goto_mode == "t"
		call util#window#focus_file(a:file, a:line, 1)
	else
		if bufname('%') != a:file
			exec "rightbelow 40vsplit " . a:file
			autocmd BufLeave <buffer> call s:split_close()
			nmap q :call <sid>split_close()<cr>
		endif

		exec a:line
		silent! foldopen
	endif
endfunction
"}}}

"{{{
function s:split_close()
	autocmd! BufLeave <buffer>
	silent! close
endfunction
"}}}

""""
"" main functions
""""
"{{{
function s:opt_menu()
	return util#pmenu#open(s:opt, "<SNR>" . s:sid . "_opt_selected", "i")
endfunction
"}}}

"{{{
function s:sym_menu(flags)
	let fdec = []
	let fdef = []
	let var = []
	let macro = []
	let type = []

	if stridx(a:flags, "g") != -1
		let symtab = gtd#symtab#get("")

	else
		let symtab = gtd#symtab#get(bufname("%"))
	endif

	for val_lst in values(symtab)
		for val in val_lst
			if stridx(a:flags, "g") != -1
				let entry = [{"abbr": "  " . val.signature, "menu": val.file . ":" . val.line . " ", "kind": val.kind }]

			else
				let entry = [{"abbr": "  " . val.signature, "menu": bufname("%") . ":" . val.line . " ", "kind": val.kind }]
			endif

			if val.kind == "p"
				let fdec += entry
			elseif val.kind == "f"
				let fdef += entry
			elseif val.kind == "d"
				let macro += entry
			elseif val.kind == "v"
				let var += entry
			else
				let type += entry
			endif
		endfor
	endfor

	return 	util#pmenu#open(fdec + fdef + macro + var + type, "<SNR>" . s:sid . "_sym_selected", "i")
endfunction
"}}}

"{{{
function s:sym_lookup(sym, file, type, flags)
	let syms = gtd#symtab#lookup(a:sym, a:file, a:type, a:flags)
	let len = len(syms)

	if stridx(a:flags, "t") != -1
		let s:goto_mode = "t"
	else
		let s:goto_mode = "s"
	endif

	if len == 1
		call s:sym_focus(syms[0].file, syms[0].line)

	elseif len > 1
		let menu = []

		for e in syms
			let menu += [{"abbr": e.signature, "menu": e.file . ":" . e.line . " ", "kind": e.kind }]
		endfor

		return util#pmenu#open(menu, "<SNR>" . s:sid . "_sym_selected", "i")
	endif

	return "\<esc>"
endfunction
"}}}

"{{{
function s:fct_head(flags)
	let line = line('.')
	let symtab = gtd#symtab#get(bufname("%"))

	let rval = { "line": 0}

	for val_lst in values(symtab)
		for val in val_lst
			if val.kind == "f" && str2nr(val.line) > str2nr(rval.line) && str2nr(val.line) <= line
				let rval = val
			endif
		endfor
	endfor

	if rval.line != 0 && a:flags == "l"
		echom rval.signature
	elseif rval.line != 0 && a:flags == "g"
		exec rval.line
	endif
endfunction
"}}}

""""
"" commands
""""
"{{{
command -nargs=0 GtdSymtabPrint	call gtd#symtab#print()
"}}}

""""
"" autocommands
""""
"{{{
autocmd BufWritePost	*.c,*.cc,*.cpp,*.h		call gtd#symtab#update(bufname("%"))
"}}}

""""
"" mappings
""""
"{{{
exec "nmap " . g:gtd_key_head_focus		. " :call <sid>fct_head('g')<cr>"
exec "nmap " . g:gtd_key_head_list		. " :call <sid>fct_head('l')<cr>"

exec "nmap " . g:gtd_key_decl_split		. " <insert><c-r>=<sid>sym_lookup(expand('<cword>'), bufname('%'), 'p', 's')<cr>"
exec "nmap " . g:gtd_key_decl_tab		. " <insert><c-r>=<sid>sym_lookup(expand('<cword>'), bufname('%'), 'p', 't')<cr>"
exec "nmap " . g:gtd_key_def_split		. " <insert><c-r>=<sid>sym_lookup(expand('<cword>'), bufname('%'), 'f', 's')<cr>"
exec "nmap " . g:gtd_key_def_tab		. " <insert><c-r>=<sid>sym_lookup(expand('<cword>'), bufname('%'), 'f', 't')<cr>"

exec "nmap " . g:gtd_key_decl_split		. " <insert><c-r>=<sid>sym_lookup(expand('<cword>'), bufname('%'), 'p', 'gs')<cr>"
exec "nmap " . g:gtd_key_decl_tab		. " <insert><c-r>=<sid>sym_lookup(expand('<cword>'), bufname('%'), 'p', 'gt')<cr>"
exec "nmap " . g:gtd_key_def_split		. " <insert><c-r>=<sid>sym_lookup(expand('<cword>'), bufname('%'), 'f', 'gs')<cr>"
exec "nmap " . g:gtd_key_def_tab		. " <insert><c-r>=<sid>sym_lookup(expand('<cword>'), bufname('%'), 'f', 'gt')<cr>"

exec "nmap " . g:gtd_key_opt_menu		. " <insert><c-r>=<sid>opt_menu()<cr>"
exec "nmap " . g:gtd_key_sym_menu_loc	. " <insert><c-r>=<sid>sym_menu('l')<cr>"
exec "nmap " . g:gtd_key_sym_menu_glob	. " <insert><c-r>=<sid>sym_menu('g')<cr>"
"}}}
