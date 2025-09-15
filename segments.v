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

fn (mut cr1 []ColorRune) joincrs(cr2 []ColorRune) {
    if cr1.len == 0 {
        cr1 = cr2.clone()
        return
    }
    joint := colorify(pl_symbol, cr1.last().bg, cr2.first().bg)
    cr1 << joint
    cr1 << cr2
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

struct Cwd {
}

//fn (cr []ColorRune) joindircr([]ColorRune) {

//}

fn (cwd &Cwd) getrunes() []ColorRune {
    mut cr := []ColorRune{}
    mut inhome := false
    mut inroot := false
    mut dirtrunc := 0
	wd := os.getwd()
    hd := os.home_dir()
    ws := wd.split(os.path_separator)[1..]
    hs := hd.split(os.path_separator)[1..]
    if ws.len > 2 {
        if wd[hd.len-1] == hd[hd.len-1] {
            inhome = true
        }
    }
    if wd == "/" || wd == "C:\\" {
        inroot = true
    }

    if inhome {
       mut c := colorify("~", home_fg, home_bg)
       c.add_padding(padding)
       cr << c
    } else if inroot {
       if ws[0] == "" {
          mut c := colorify("/", path_fg, path_bg)
          c.add_padding(padding)
          cr << c
          return cr
       }
    }

    mut cr2 := []ColorRune{}

    if inhome {
        for i, s in ws[hs.len..] {
            mut c := []ColorRune{}
            if i == ws.len-hs.len-1 {
                c = colorify(s, cwd_fg, path_bg)
            } else {
                c = colorify(s, path_fg, path_bg)
            }

            c.add_padding(padding)
            if i != 0 {
                mut c2 := colorify(separator, path_fg, path_bg)
                cr2 << c2
            }
            cr2 << c
        }
        cr.joincrs(cr2)
    } else {
        for i, s in ws {
            mut c := []ColorRune{}
            println(s)
            if i == ws.len-1 {
                c = colorify(s, cwd_fg, path_bg)
            } else {
                c = colorify(s, path_fg, path_bg)
            }

            c.add_padding(padding)
            if i != 0 {
                mut c2 := colorify(separator, path_fg, path_bg)
                cr2 << c2
            }
            cr2 << c
        }
        cr.joincrs(cr2)
    }

    return cr
}

// end dollar or percentage $ %
struct PromptEnd {
}

fn (pe &PromptEnd) getrunes() []ColorRune {
    mut cr := []ColorRune{}
	cr << ColorRune{
        bg: cmd_passed_bg,
        fg: cmd_passed_fg,
        text: prompt_end.runes().first(),
    }
    cr.add_padding(1)
    return cr
}