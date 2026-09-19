module main

import os
//import math

const cwd_truncate = 4

struct Cwd {
}

//fn (cr []ColorRune) joindircr([]ColorRune) {

//}

fn (cwd &Cwd) getrunes() []ColorRune {
    mut cr := []ColorRune{cap: colorrune_cap_mid}
    mut inhome := false
    mut inroot := false
    mut rootstr := "/"
    //mut dirtrunc := 0
	wd := os.getwd()
    hd := os.home_dir()
    ws := wd.split(os.path_separator)[1..]
    hs := hd.split(os.path_separator)[1..]
    if ws.len > 1 {
        if ws[hs.len-1] == hs[hs.len-1] {
            inhome = true
        }
    }
    $if windows {
        if wd.runes()[1] == `:` {
            inroot = true
            rootstr = wd.runes()[..2].string()
        }
    } $else {
        if wd == "/" {
            inroot = true
        }
    }


    if inhome {
       mut c := colorify("~", home_fg, home_bg)
       c.add_padding(padding)
       cr << c
       if ws.len == hs.len {
        return cr
       }
    } else if inroot {
       if ws[0] == "" {
          mut c := colorify(rootstr, cwd_fg, path_bg)
          c.add_padding(padding)
          cr << c
          return cr
       }
    }

    mut cr2 := []ColorRune{}

	homelen := if inhome { hs.len } else { 0 }
	//trunc := int(math.ceil(cwd_truncate/2))


    for i, mut s in ws[homelen..] {
        mut c := []ColorRune{}
        if i == ws.len-homelen-1 {
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
    return cr
}