if exists('g:loaded_gtd_symtab') || &compatible
	finish
endif

let g:loaded_gtd_symtab = 1

""""
" local variables
""""
"{{{
"{{{
" ctags config
let s:ctags_kinds_c = "cdfglpstuvx"
let s:ctags_kinds_asm = "dlmt"
let s:ctags_kinds_vim = "fvmc"
let s:ctags_kinds_sh = "f"
let s:ctags_kinds_make = "m"
let s:ctags_kinds_python = "cfv"
let s:ctags_kinds_java = "cegilm"
let s:ctags_fields = "zknl"
let s:ctags_extras = ""
let s:ctags_args = "-R --filter=yes --languages=c,c++,asm,vim,sh,make,python,java"

let s:ctags_cmd = 
	\ "ctags " . s:ctags_args
	\ . " --extra=" . s:ctags_extras
	\ . " --fields=" . s:ctags_fields
	\ . " --c-kinds=" . s:ctags_kinds_c
	\ . " --c++-kinds=" . s:ctags_kinds_c
	\ . " --asm-kinds=" . s:ctags_kinds_asm
	\ . " --vim-kinds=" . s:ctags_kinds_vim
	\ . " --sh-kinds=" . s:ctags_kinds_sh
	\ . " --make-kinds=" . s:ctags_kinds_make
	\ . " --python-kinds=" . s:ctags_kinds_python
	\ . " --java-kinds=" . s:ctags_kinds_java
"}}}

"{{{
" symbol tables
let s:symtab_file = {}
let s:symtab = {}
"}}}

"{{{
" long names for ctags kinds
let s:kinds_longnames = {
	\ "Asm" : {
		\ "d" : "defines",
		\ "l" : "labels",
		\ "m" : "macros",
		\ "t" : "types",
		\ "func_kind" : "l",
		\ "proto_kind" : "",
	\ },
	\
	\ "C": {
		\ "c" : "classes",
		\ "d" : "macros",
		\ "e" : "enum constants",
		\ "f" : "functions",
		\ "g" : "enums",
		\ "l" : "local variables",
		\ "m" : "members",
		\ "n" : "namespaces",
		\ "p" : "prototypes",
		\ "s" : "structures",
		\ "t" : "typedefs",
		\ "u" : "unions",
		\ "v" : "variable",
		\ "x" : "external and forward variable declarations",
		\ "func_kind" : "f",
		\ "proto_kind" : "p",
	\ },
	\
	\ "Vim" : {
 		\ "a" : "autocommand groups",
 		\ "c" : "commands",
 		\ "f" : "functions",
 		\ "m" : "maps",
 		\ "v" : "variables",
		\ "func_kind" : "f",
		\ "proto_kind" : "",
	\ },
	\
	\ "Sh" : {
		\ "f" : "functions",
		\ "func_kind" : "f",
		\ "proto_kind" : "",
	\ },
	\
	\ "Make" : {
		\ "m": "macros",
		\ "func_kind" : "m",
		\ "proto_kind" : "",
	\ },
	\
	\ "Python" : {
		\ "c" : "classes",
		\ "f" : "functions",
		\ "m" : "class members",
		\ "v" : "variables",
		\ "i" : "imports",
		\ "func_kind" : "f",
		\ "proto_kind" : "",
	\ },
	\
	\ "Java" : {
		\ "c" : "classes",
		\ "e" : "enum constants",
		\ "f" : "fields",
		\ "g" : "enums",
		\ "i" : "interfaces",
		\ "l" : "local variables",
		\ "m" : "methods",
		\ "p" : "packages",
		\ "func_kind" : "m",
		\ "proto_kind" : "",
	\ },
\ }
"}}}
"}}}

""""
"" helper functions
""""
"{{{
" \brief	add (key, value) to dictionary
"
" \param	dict	target dictionary
" \param	key		indexing key
" \param	value	value to store for key
function s:sym_add(dict, key, value)
	if has_key(a:dict, a:key)
		let a:dict[a:key] += a:value
	else
		let a:dict[a:key] = a:value
	endif
endfunction
"}}}

"{{{
" \brief	check symbol list for entries with matching kind
"
" \param	sym_name	name of the symbol corresponding to lst
" \param	lst			list of symbols
" \param	kind		kind to look for
" 						'p': match everthing except function defintions
" 						'f': match everthing except function declarations
function s:sym_match(sym_name, lst, kind)
	let r = []

	for sym in a:lst
		" get kind that used for prototypes and functions
		let proto_kind = gtd#symtab#longname(s:symtab_file[sym.file].lang, "proto_kind")
		let func_kind = gtd#symtab#longname(s:symtab_file[sym.file].lang, "func_kind")

		" use symbol if either
		" 	- no prototype kind is defined for the given language
		" 	- if symbol is not a function while looking for a prototype
		" 	- or symbol is not a prototype while looking for a function 
		if proto_kind == "" || !(sym.kind == proto_kind && a:kind != "p" || sym.kind == func_kind && a:kind != "f")
			let r += [{"sym": a:sym_name, "file": sym.file, "line": sym.line, "kind": sym.kind, "signature": sym.signature}]
		endif
	endfor

	return r
endfunction
"}}}

"{{{
" \brief	perform update of symbol tables
"
" \param	cmd		ctags command string
" \param	files	files/directories that shall be parsed by ctags
function s:update(cmd, files)
	" issue ctags command
	let lines = systemlist(a:cmd, a:files)

	" parse ctags output
	for line in lines
		" find start/end of signature
		let s = stridx(line, "/^")
		let e = stridx(line, "\$/;\"", s)

		let signature = ""

		" extract signature from line if found
		if s != -1 && e != -1
			" copy signature string and remove crap
			let signature = strpart(line, s + 2, e - s - 2)
			let signature = matchstr(signature, "[a-zA-Z].*[)a-zA-Z0-9]")

			" remove signature from line
			let line = substitute(line, '/^.*\$/;\"', "", "")
		endif

		" get tokens
		let tk = split(line, '\t')

		if len(tk) < 6
			continue
		endif

		let sym = tk[0]
		let file = fnamemodify(tk[1], ':.')

		if signature == ""
			let signature = sym
		endif

		" get tokens in the form of '<key>:<value>'
		" 	excpected keys:
		" 		- file
		" 		- line
		" 		- language
		let i = 3
		while i < len(tk)
			let [key, value] = split(tk[i], ':')
			exec "let " . key . " = \"" . value . "\""
			let i += 1
		endwhile

		if language == "C++"
			let language = "C"
		endif

		" generate symtab entry
		let lst_entry = [{
			\ "file": file,
			\ "line": line,
			\ "kind": kind,
			\ "signature": signature,
			\ }]

		" add entry to global symtab
		call s:sym_add(s:symtab, sym, lst_entry)

		" init file symtab for current file
		if !has_key(s:symtab_file, file)
			let s:symtab_file[file] = {"lang": language, "syms": {}, "kinds": {}}
		endif

		" init file symtab for current kind
		if !has_key(s:symtab_file[file]["kinds"], kind)
			let s:symtab_file[file]["kinds"][kind] = {}
		endif

		" add entry to file symtab
		call s:sym_add(s:symtab_file[file]["syms"], sym, copy(lst_entry))
		call s:sym_add(s:symtab_file[file]["kinds"][kind], sym, copy(lst_entry))
	endfor
endfunction
"}}}

"{{{
" \brief	update symbol tables with files in current directory
function s:symtab_init()
	" only update of not done already
	" once initialised all updates are performed on a per-file basis
	if g:gtd_symtab_initialised < 2
		" clear symtabs from per-file initialisation performed once
		" loading this script
		let s:symtab = {}
		let s:symtab_file = {}

		" update symtabs
		call s:update(s:ctags_cmd, '.')
		let g:gtd_symtab_initialised = 2
	endif
endfunction
"}}}

""""
"" main functions
""""
"{{{
" \brief	update symtabs using given file
"
" \param	file	file to update symtabs with
function gtd#symtab#update_buf(file)
	if has_key(s:symtab_file, a:file)
		" remove file-related symbols from global symtab
		for sym in keys(s:symtab_file[a:file]["syms"])
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
" \brief	update symtabs based on open buffers
function gtd#symtab#update_openbufs()
	let bnum = 1

	" iterate through buffers
	while bnum <= bufnr("$")
		let bname = bufname(bnum)
		let bnum += 1

		" update symtab if non-emty buffer name
		if bname != ""
			call gtd#symtab#update_buf(bname)
		endif
	endwhile
endfunction
"}}}

"{{{
" \brief	print symbol tables
function gtd#symtab#print()
	echom " ==================="
	echom "global symbol table (" . len(s:symtab) . " symbol(s))"

	for sym in keys(s:symtab)
		echom "  " . sym
		for entry in s:symtab[sym]
			echom   "    " . entry.file . ":" . entry.line . " " . entry.kind . " " . entry.signature
		endfor
	endfor

	echom " "
	echom "symbol table per file (" . len(s:symtab_file) . " file(s))"

	for file in keys(s:symtab_file)
		echom " " . file . ":" . s:symtab_file[file].lang . " (" . len(s:symtab_file[file]["syms"]) . " symbol(s))"

		for sym in keys(s:symtab_file[file]["syms"])
			for entry in s:symtab_file[file]["syms"][sym]
				echom "    " . sym . ": " . entry.line . " " . entry.kind . " " . entry.signature
			endfor
		endfor
		echom " "

		for kind in keys(s:symtab_file[file]["kinds"])
			echom "    " . s:kinds_longnames[s:symtab_file[file].lang][kind]

			for sym in keys(s:symtab_file[file]["kinds"][kind])
				for entry in s:symtab_file[file]["kinds"][kind][sym]
					echom "    " . sym . ": " . entry.line . " " . entry.kind . " " . entry.signature
				endfor
			endfor
			echom " "
		endfor

		echom " "
	endfor

	echom " ==================="
	echom " "
endfunction
"}}}

"{{{
" \brief	perform symtab lookup
"
" \param	sym		symbol name to look for
" \param	file	file name used for file-local search
" \param	kind	kind to look for
" 					'p': match everthing except function defintions
" 					'f': match everthing except function declarations
" \param	flags	'g': perform lookup in global symtab only
"
" \return	list of symbols
function gtd#symtab#lookup(sym, file, kind, flags)
	" lookup symbol in symtab_file
	if stridx(a:flags, "g") == -1
		if !has_key(s:symtab_file, a:file)
			echom "no symbol table for file " . a:file
			return []
		endif

		if has_key(s:symtab_file[a:file]["syms"], a:sym)
			let r = s:sym_match(a:sym, s:symtab_file[a:file]["syms"][a:sym], a:kind)
		
			if len(r) > 0
				return r
			endif
		endif
	endif

	call s:symtab_init()

	" lookup symbol in symtab if no symbol of specified kind found
	if !has_key(s:symtab, a:sym)
		echom "no entry for symbol " . a:sym
		return []
	endif

	return s:sym_match(a:sym, s:symtab[a:sym], a:kind)
endfunction
"}}}

"{{{
" \brief	return per-file symtab for given file
"
" \param	file	file identifying requested symtab
"
" \return	symtab if available, {} otherwise
function gtd#symtab#get(file)
	if has_key(s:symtab_file, a:file)
		return s:symtab_file[a:file]
	endif

	return {}
endfunction
"}}}

"{{{
" \brief	get kind long-name
"
" \param	lang	language
" \param	kind	kind
"
" \return	long name kind for given language
function gtd#symtab#longname(lang, kind)
	return s:kinds_longnames[a:lang][a:kind]
endfunction
"}}}

""""
"" initialisation
""""
" initialise symtabs based on open buffers
call gtd#symtab#update_openbufs()
let g:gtd_symtab_initialised = 1
