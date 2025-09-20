module main

import os
// import strings

// #flag -lgit2
// #include <git2.h>

// plz make first element to be a root directory
// it returns path
@[direct_array_access; inline]
fn git_get_gitdir_from_dir(splittedpath []string) string {
	mut path := ""
	$if windows {
		path += splittedpath[0] + os.path_separator
	} $else {
		path += splittedpath[0]
	} 
	for i := 1; i < splittedpath.len; i++ {
		path += splittedpath[i]
		path += os.path_separator
		if os.is_readable(path + ".git") {
			return path
		}
	}
	return ""
}

// maybe fast
/*@[direct_array_access; inline]
fn get_gitdir_from_dir(splittedpath []string) string {
	mut path := []u8{cap: 256}
	mut strbuf := strings.new_builder(256)
	$if windows {
		path << splittedpath[0].bytes()
		path << os.path_separator.bytes()
	} $else {
		path << splittedpath[0].bytes()
	} 
	for i := $if windows {0} $else {1}; i < splittedpath.len + $if windows {0} $else {1}; i++ {
		path << splittedpath[i].bytes()
		path << os.path_separator.bytes()
		strbuf.write(path) or {  }
		strbuf.write_string(".git")
		if os.is_readable(strbuf.str()) {
			return path.bytestr()
		}
		strbuf.clear()
	}
	return ""
}*/

// slow
/*@[typedef]
struct C.git_repository {}

fn C.git_libgit2_init() int

fn C.git_repository_open(out &&C.git_repository, path &char) int

fn C.git_repository_free(git_repository &C.git_repository);

fn git_getchanges(path string) {
	mut repo := &voidptr(unsafe { nil })
	C.git_libgit2_init()
	ret := C.git_repository_open(&repo, path.str)
	if ret != 0 {
    eprintln("failed to open repo (code=$ret)")
} else {
    println("opened repo ok")
    C.git_repository_free(repo)
}
}*/

// s must be directory that including .git

fn git_get_head(s string) (string, bool) {
	gitdir := s + os.path_separator + ".git"
	head := os.read_file(gitdir+os.path_separator+"HEAD") or {return "", false}.trim_space()
	if head.starts_with("ref:") {
		return head.all_after_last("/"), false
	} else {
		return head[..7], true
	}
	return "", false
}

struct Git{}

fn (g Git) getrunes() []ColorRune {
	mut cr := []ColorRune{}

	wd := os.getwd()
    mut ws := wd.split(os.path_separator)
	$if windows {
	} $else {
		ws[0] = os.path_separator
		if ws.last() == "" {
			ws = unsafe { ws[..1] }
		}
	}
	gd := git_get_gitdir_from_dir(ws)
	head, detached := git_get_head(gd)
	if head != "" {
		if detached {
			cr = colorify(git_symbol + " ⚓ " + head, git_clean_fg, git_clean_bg)
		} else {
			cr = colorify(git_symbol + " " + head, git_clean_fg, git_clean_bg)
		}
		cr.add_padding(1)
	}
	return cr
}