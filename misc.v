module main

import os

fn (mut cr []ColorRune) fill_until(num int, run ColorRune) {
	l := cr.len
	for _ in 0..num-l {
		cr << run
	}
}

enum Lang {
	nothing = -1
	bash
	c
	commonlisp
	css
	cxx
	go
	haskell
	html
	java
	javascript
	kotlin
	llvm
	lua
	perl
	python
	ruby
	rust
	scala
	scheme
	shellscript
	typescript
	v
	vimscript
	zig
	zsh
}

fn getbestlang(lmap map[Lang]int) (Lang, int) {
	mut bestlang := Lang.nothing
	mut bestval := 0

	for k, v in lmap {
		if bestval < v {
			bestval = v
			bestlang = k
		}
	}
	return bestlang, bestval
}

const dlang_filelimit = 64
const dlang_depthlimit = 5

fn detect_lang(nested int, mut fcnt &int) (Lang, int) {
	mut lmap := map[Lang]int{}
	mut files := os.ls(".") or { return Lang.nothing, 0 }
	//extention
	for _, s in files {
		if s.starts_with(".") {
			continue
		}
		fcnt++
		if os.is_dir(s) && nested < dlang_depthlimit {
			wd := os.getwd()
			os.chdir(s) or { }
			lng, vl := detect_lang(nested+1,mut &fcnt)
			lmap[lng] += vl
			os.chdir(wd) or { }
		}
		fname := os.file_ext(s)
		match fname {
			".bash" {
				lmap[Lang.bash]++
			}
			".c", ".h" {
				lmap[Lang.c]++
			}
			".lisp", ".lsp", ".cl", ".el" {
				lmap[Lang.commonlisp]++
			}
			".css" {
				lmap[Lang.css]++
			}
			".cc", ".hh", ".cpp", ".hpp", ".cxx", ".hxx" {
				lmap[Lang.cxx]++
			}
			".go" {
				lmap[Lang.go]++
			}
			".hs" {
				lmap[Lang.haskell]++
			}
			".html", ".htm" {
				lmap[Lang.html]++
			}
			".java" {
				lmap[Lang.java]++
			}
			".js", ".mjs", ".cjs" {
				lmap[Lang.javascript]++
			}
			".kt", ".kts" {
				lmap[Lang.kotlin]++
			}
			".ll", ".mlir" {
				lmap[Lang.llvm]++
			}
			".lua" {
				lmap[Lang.lua]++
			}
			".pl", ".pm", ".t" {
				lmap[Lang.perl]++
			}
			".py", ".pyw", ".pyi", ".pyc" {
				lmap[Lang.python]++
			}
			".rb", ".erb", ".rake" {
				lmap[Lang.ruby]++
			}
			".rs" {
				lmap[Lang.rust]++
			}
			".scala", ".sc" {
				lmap[Lang.scala]++
			}
			".scm", ".ss" {
				lmap[Lang.scheme]++
			}
			".sh" {
				lmap[Lang.shellscript]++
			}
			".ts", ".tsx" {
				lmap[Lang.typescript]++
			}
			".v", ".vv" {
				lmap[Lang.v]++
			}
			".vim" {
				lmap[Lang.vimscript]++
			}
			".zig" {
				lmap[Lang.zig]++
			}
			else {}
		}
		if fcnt > dlang_filelimit {
			return getbestlang(lmap)
		}
	}

	// filename for detecting go.mod or v.mod, and some like cargo.toml
	for _, s in files {
		match s {
			"go.mod", "go.sum" {
				lmap[Lang.go]++
			}
			"Cargo.toml", "Cargo.lock" {
				lmap[Lang.rust]++
			}
			else {}
		}
	}
	if fcnt > dlang_filelimit {
		return getbestlang(lmap)
	}

	return getbestlang(lmap)
}