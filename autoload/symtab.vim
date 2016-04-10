if exists('g:loaded_gtd_symtab') || &compatible
	finish
endif

let g:loaded_gtd_symtab = 1


" config variables
let s:ctags_kinds = "cdfglpstuvx"
let s:ctags_fields = "zkn"
let s:ctags_extras = ""
let s:ctags_args = "--languages=c,c++"

let s:ctags_cmd = 
	\ "ctags -R --filter=yes " . s:ctags_args
	\ . " --c-kinds=" . s:ctags_kinds
	\ . " --c++-kinds=" . s:ctags_kinds
	\ . " --fields=" . s:ctags_fields
	\ . " --extra=" . s:ctags_extras

let s:symtab_file = {}
let s:symtab = {}


""""
"" helper functions
""""
"{{{
function s:sym_add(dict, key, value)
	if has_key(a:dict, a:key)
		let a:dict[a:key] += a:value
	else
		let a:dict[a:key] = a:value
	endif
endfunction
"}}}

"{{{
function s:update(cmd, input)
	let lines = systemlist(a:cmd, a:input)

	for line in lines
		let s = stridx(line, "/^")
		let e = stridx(line, "\$/;\"", s)

		let signature = strpart(line, s + 2, e - s - 2)
		let line = substitute(line, '\t/^' . signature . '\$/;\"', "", "")

		let signature = matchstr(signature, "[a-zA-Z].*[)a-zA-Z0-9]")
		let tk = split(line, '\t')

		if len(tk) < 4
			continue
		endif

		let sym = tk[0]
		let file = fnamemodify(tk[1], ':.')

		let e_glob = [{
			\ "file": file,
			\ "line": split(tk[3], ':')[1],
			\ "kind": split(tk[2], ':')[1],
			\ "signature": signature,
			\ }]

		let e_file = [{
			\ "line": split(tk[3], ':')[1],
			\ "kind": split(tk[2], ':')[1],
			\ "signature": signature,
			\ }]

		call s:sym_add(s:symtab, sym, e_glob)

		if !has_key(s:symtab_file, file)
			let s:symtab_file[file] = {}
		endif

		call s:sym_add(s:symtab_file[file], sym, e_file)
	endfor
endfunction
"}}}

""""
"" main functions
""""
"{{{
function gtd#symtab#print()
	echom " ==================="
	echom "global symbol table (" . len(s:symtab) . " symbol(s))"

	for sym in keys(s:symtab)
		for entry in s:symtab[sym]
			echom   "  " . sym . ": " . entry.file . ":" . entry.line . " " . entry.kind . " " . entry.signature
		endfor
	endfor

	echom " "
	echom "symbol table per file (" . len(s:symtab_file) . " file(s))"

	for file in keys(s:symtab_file)
		echom " " . file . " (" . len(s:symtab_file[file]) . " symbol(s))"

		for sym in keys(s:symtab_file[file])
			for entry in s:symtab_file[file][sym]
				echom "    " . sym . ": " . entry.line . " " . entry.kind . " " . entry.signature
			endfor
		endfor

		echom " "
	endfor

	echom " ==================="
	echom " "
endfunction
"}}}

"{{{
function gtd#symtab#lookup(sym, file, kind, flags)
	let r = []

	" lookup symbol in symtab_file
	if stridx(a:flags, "g") == -1
		if !has_key(s:symtab_file, a:file)
			echom "no symbol table for file " . a:file
			return []
		endif

		if has_key(s:symtab_file[a:file], a:sym)
			for sym in s:symtab_file[a:file][a:sym]
				if !(sym.kind == "p" && a:kind != "p" || sym.kind == "f" && a:kind != "f")
					let r += [{"sym": a:sym, "file": a:file, "line": sym.line, "kind":sym.kind, "signature": sym.signature}]
				endif
			endfor
		
			if len(r) > 0
				echom string(r)
				return r
			endif
		endif
	endif

	" lookup symbol in symtab if no symbol of specified kind found
	if !has_key(s:symtab, a:sym)
		echom "no entry for symbol " . a:sym
		return []
	endif

	for item in s:symtab[a:sym]
		if !(item.kind == "p" && a:kind != "p" || item.kind == "f" && a:kind != "f")
			let r += [{"sym": a:sym, "file": item.file, "line": item.line, "kind": item.kind, "signature": item.signature}]
		endif
	endfor

	return r
endfunction
"}}}

"{{{
function gtd#symtab#update(file)
	if has_key(s:symtab_file, a:file)
		" remove file-related symbols from global symtab
		for sym in keys(s:symtab_file[a:file])
			let i = len(s:symtab[sym]) - 1
			
			while i >= 0
				if s:symtab[sym][i].file == a:file
					call remove(s:symtab[sym], i)

					if len(s:symtab[sym]) == 0
						call remove(s:symtab, sym)
					endif
				endif

				let i = i - 1
			endwhile
		endfor

		" clear entry for file in symtab_file
		call remove(s:symtab_file, a:file)
	endif

	" parse symbols of a:file
	call s:update(s:ctags_cmd, a:file)
endfunction
"}}}

"{{{
function gtd#symtab#get(file)
	if a:file == ""
		return s:symtab
	endif

	if has_key(s:symtab_file, a:file)
		return s:symtab_file[a:file]
	endif

	return {}
endfunction
"}}}

""""
"" initialisation
""""

" initialise symbol tables for current directory
call s:update(s:ctags_cmd, 
	\   globpath('.', "**/*.h") . "\n"
	\ . globpath('.', "**/*.c") . "\n"
	\ . globpath('.', "**/*.cc") . "\n"
	\ . globpath('.', "**/*.cpp") . "\n"
\ )
