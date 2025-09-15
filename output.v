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

fn (cr []ColorRune) output_term() string {
	mut out := ""
	for c in cr {
		out += "\x1b[38;5;" + c.fg.str() + "\x1b[48;5;" + c.bg.str() + c.text.str()
	}
	return out
}

fn (cr []ColorRune) output_zsh() string {
	mut out := ""
	for c in cr {
		out += "%{\x1b[38;5;" +c.fg.str() +"m%}%{\x1b[48;5;" + c.bg.str() +"m%}"+c.text.str()
	}
	out += "%{\x1b[0m%}"
	return out
}