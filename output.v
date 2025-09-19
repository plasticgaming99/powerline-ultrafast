module main

import strings

fn (cr []ColorRune) terminate() []ColorRune {
	mut c := cr.last()
	c.text = pl_symbol.runes().first()
	//cf := c.fg
	c.fg = c.bg
	c.bg = 0
	mut crn := []ColorRune{}
	crn << cr
	crn << c
	return crn
}

fn (cr []ColorRune) terminate_right() []ColorRune {
	if cr.len == 0 {
		return []ColorRune{}
	}
	mut c := cr.first()
	c.text = pl_symbol_r.runes().first()
	//cf := c.fg
	c.fg = c.bg
	c.bg = 0
	mut crn := []ColorRune{}
	crn << c
	crn << cr
	return crn
}

fn (cr []ColorRune) output_term() string {
	mut out := ""
	for c in cr {
		out += "\x1b[38;5;" + c.fg.str() + "\x1b[48;5;" + c.bg.str() + c.text.str()
	}
	return out
}

fn (cr []ColorRune) output_zsh() string {
	mut sb := strings.new_builder(1024)
	for c in cr {
		sb.write_string("%{\x1b[38;5;")
		sb.write_string(c.fg.str())
		sb.write_string("m%}%{\x1b[48;5;")
		sb.write_string(c.bg.str())
		sb.write_string("m%}")
		sb.write_string(c.text.str())
	}
	sb.write_string("%{\x1b[0m%}")
	return sb.str()
}