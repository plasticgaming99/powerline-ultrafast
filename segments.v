module main

import os

fn colorify(s string, cfg int, cbg int) []ColorRune {
    mut cr := []ColorRune{}
    for r in s.runes() {
        cr << ColorRune{
            fg: cfg
            bg: cbg
            text: r
        }
    }
    return cr
}

fn joincrs(cr1 []ColorRune, cr2 []ColorRune) []ColorRune {
    mut cr := []ColorRune
    joint := colorify(pl_symbol, cr1.first().bg, cr2.last().bg)
    cr << cr1
    cr << joint
    cr << cr2
    return cr
}

fn (mut cr []ColorRune) terminate() {

}

fn (mut cr []ColorRune) add_padding(val int) {
    mut p := cr[0]
    p.text = ` `
    mut f := cr.last()
    f.text = ` `
    cr.insert(0, p)
    cr << f
}

struct Username{
}

fn (username &Username) getrunes() []ColorRune {
    mut cr := []ColorRune{}
    cr = colorify(getcurrentusername(), user_fg, user_bg)
    cr.add_padding(padding)
    return cr
}

struct Hostname{
}

fn (hostname &Hostname) getrunes() []ColorRune {
	mut cr := []ColorRune{}
    cr = colorify(os.hostname() or {"unknown"}, host_fg, host_bg)
    cr.add_padding(padding)
    return cr
}

struct HomeDir{
}

fn (homedir &HomeDir) getrunes() {

}

struct Cwd {
}

fn (cwd &Cwd) getrunes() {
    mut inhome := false
	wd := os.getwd()
    hd := os.home_dir()
    ws := wd.split(os.path_separator)
    hs := hd.split(os.path_separator)
    if wd[hd.len-1] == hd[hd.len-1] {
        inhome = true
    }
}

// end dollar or percentage $ %
struct Root {
}

fn (root &Root) getrunes() {
	
}