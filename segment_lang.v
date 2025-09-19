module main

import os
import x.json2

struct LangVersionCache {
mut:
	bash string
	c string
	//commonlisp string
	//css string
	cxx string
	go string
	haskell string
	//html string
	java string
	javascript string
	kotlin string
	llvm string
	lua string
	perl string
	python string
	ruby string
	rust string
	scala string
	//scheme string
	shellscript string
	typescript string
	v string
	vimscript string
	zig string
	zsh string
}

fn (mut lvc LangVersionCache) check_version() {
	{
		b := os.execute("bash -c 'echo \$BASH_VERSION'")
		lvc.bash = b.output.before("(")
	}
	{
		mut c := os.execute("clang -dumpversion")
		if c.exit_code != 0 {
			c = os.execute("gcc -dumpfullversion")
		}
		lvc.c = c.output.trim_space()
	}
	{
		mut c := os.execute("clang++ -dumpversion")
		if c.exit_code != 0 {
			c = os.execute("g++ -dumpfullversion")
		}
		lvc.cxx = c.output.trim_space()
	}
	{
		g := os.execute("go version")
		lvc.go = g.output.after("version ").before(" ").after("go")
	}
	{
		h := os.execute("ghc --version")
		lvc.haskell = h.output.after("version ").trim_space()
	}
	{
		j := os.execute("java --version")
		lvc.java = j.output.split(" ")[1]
	}
	{
		j := os.execute("node --version")
		lvc.javascript = j.output.trim_space()
	}
	{
		l := os.execute("llvm-config --version")
		lvc.llvm = l.output.trim_space()
	}
	{
		l := os.execute("luajit -v")
		lvc.lua = l.output.split(" ")[1]
	}
	{
		p := os.execute("perl -e 'print $^V'")
		lvc.perl = p.output.trim_space()
	}
	{
		p := os.execute("python -c 'import platform;print(platform.python_version())'")
		lvc.python = p.output.trim_space()
	}
	{
		r := os.execute("ruby -v")
		lvc.ruby = r.output.split(" ")[1]
	}
	{
		r := os.execute("rustc --version")
		lvc.rust = r.output.split(" ")[1]
	}
	{
		s := os.execute("scala --version")
		lvc.scala = s.output.after("version ").before("-")
	}
	{
		lvc.shellscript = ""
	}
	{
		t := os.execute("node --version")
		lvc.typescript = t.output.trim_space()
	}
	{
		v := os.execute("v version")
		lvc.v = v.output.split(" ")[1]
	}
	{
		v := os.execute("vim --version")
		lvc.vimscript = v.output.after("VIM - Vi IMproved").split(" ")[0]
	}
	{
		z := os.execute("zig version")
		lvc.zig = z.output.trim_space()
	}
	{
		z := os.execute("zsh --version")
		lvc.zsh = z.output.split(" ")[1]
	}
	return
}

fn (mut lvc LangVersionCache) get_version() {
	cache := os.environ()["PLUF_LANG_CACHE"] or { "" }
	if cache == "" {
		lvc.check_version()
		return
	}

	lvc = json2.decode[LangVersionCache](cache) or {
		lvc.check_version()
		return
	}
}

fn dump_cache() string {
	mut lvc := LangVersionCache{}
	lvc.check_version()
	j := json2.encode[LangVersionCache](lvc)
	return j
}

struct LangVersion{
mut:
	lvc LangVersionCache
}

fn (lv &LangVersion) getrunes() []ColorRune {
    mut cr := []ColorRune{}
    mut cnt := 0
    ln, _ := detect_lang(0, mut &cnt)
	mut verstr := ""
    match ln {
        .bash {}
        .c {verstr = lang_c_icon + " " + lv.lvc.c}
        //.commonlisp {}
	    //.css {}
	    .cxx {verstr = lang_c_icon + " " + lv.lvc.cxx}
	    .go {verstr = lang_go_icon + " " + lv.lvc.go}
	    .haskell {verstr = lang_haskell_icon + " " + lv.lvc.haskell}
	    //.html {}
	    .java {verstr = lang_java_icon + " " + lv.lvc.java}
	    .javascript {verstr = lang_nodejs_icon + " " + lv.lvc.javascript}
	    .kotlin {verstr = lang_kotlin_icon + " " + lv.lvc.kotlin}
	    .llvm {verstr = lang_llvm_icon + " " + lv.lvc.llvm}
	    .lua {verstr = lang_lua_icon + " " + lv.lvc.lua}
	    .perl {verstr = lang_perl_icon + " " + lv.lvc.perl}
	    .python {verstr = lang_python_icon + " " + lv.lvc.python}
	    .ruby {verstr = lang_ruby_icon + " " + lv.lvc.ruby}
	    .rust {verstr = lang_rust_icon + " " + lv.lvc.rust}
	    .scala {}
	    //.scheme {}
	    .shellscript {}
	    .typescript {verstr = lang_nodejs_icon + " " + lv.lvc.v}
	    .v {verstr = lang_v_icon + " " + lv.lvc.v}
	    .vimscript {verstr = lang_vim_icon + " " + lv.lvc.vimscript}
	    .zig {verstr = lang_zig_icon + " " + lv.lvc.zig}
	    .zsh {verstr = "%_ " + lv.lvc.zsh}
        else {}
    }
	if verstr != "" {
		mut c := colorify(verstr, cwd_fg, path_bg)
		c.add_padding(padding)
		cr = c.clone()
	}
    return cr
}