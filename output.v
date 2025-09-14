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
	return out
}