// now fg -1 bg -1 means ansi reset all

module main

import strings

fn (cr []ColorRune) terminate() []ColorRune {
	mut c := cr.last()
	c.text = pl_symbol.runes().first()
	//cf := c.fg
	c.fg = c.bg
	c.bg = "-1"
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
	c.bg = "0"
	mut crn := []ColorRune{}
	crn << c
	crn << cr
	return crn
}

fn (cr []ColorRune) output_term() string {
	mut out := ""
	for c in cr {
		if c.fg == "-1" && c.bg == "-1" {
			out += "\x1b[0m"
			continue
		}
		out += "\x1b[38;5;" + c.fg.str() + "\x1b[48;5;" + c.bg.str() + c.text.str()
	}
	out += "\x1b[0m"
	return out
}

fn (cr []ColorRune) output_zsh() string {
	mut sb := strings.new_builder(1024)
	for c in cr {
		if c.fg == "-1" && c.bg == "-1" {
			sb.write_string("%{\x1b[0m%}")
			sb.write_string(c.text.str())
			continue
		}
		if c.fg == "-1" || c.bg == "-1" {
			sb.write_string("%{\x1b[0m%}")
		}
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

// from here output optimizer begins
struct ColoredSeqeuence {
mut:
	runes  []rune
	fgseq map[int]string
	bgseq map[int]string
	resetseq []int
}

fn init_optimizer() ColoredSeqeuence {
	return ColoredSeqeuence{
		runes: []rune{cap: colorrune_cap_large}
		fgseq: map[int]string
		bgseq: map[int]string
		resetseq: []int{cap:colorrune_cap_small}
	}
}

fn (mut cs ColoredSeqeuence) optimize_crs(crs []ColorRune) {
	mut prevfg := []rune{cap:20}
	mut prevbg := []rune{cap:20}
	for i := crs.len-1; i > -1; i-- {
		mut fgb := crs[i].fg.runes()
		mut bgb := crs[i].bg.runes()

		if fgb == [`-`, `1`] || bgb == [`-`, `1`] {
			cs.resetseq << i
		}

		if fgb != prevfg {
			cs.fgseq[i+1] = prevfg.string()
			prevfg = fgb.clone()
		}

		if bgb != prevbg {
			cs.bgseq[i+1] = prevbg.string()
			prevbg = bgb.clone()
		}

		if i == 0 {
			cs.fgseq[i] = fgb.string()
			cs.bgseq[i] = bgb.string()
		}
	}

	for i := 0; i < crs.len; i++ {
		cs.runes << crs[i].text
	}
}

fn (cs &ColoredSeqeuence) output_zsh_opt() string {
	mut byteslc := []rune{cap:1024}
	for i := 0; i < cs.runes.len; i++ {
		if i in cs.resetseq {
			byteslc << "%{\x1b[0m%}".runes()
		}

		fg := cs.fgseq[i]
		if fg != "" {
			byteslc << "%{\x1b[38;5;".runes()
			byteslc << fg.str().runes()
			byteslc << "m%}".runes()
		}

		bg := cs.bgseq[i]
		if bg != "" {
			byteslc << "%{\x1b[48;5;".runes()
			byteslc << bg.str().runes()
			byteslc << "m%}".runes()
		}

		byteslc << cs.runes[i]
	}
	byteslc << "%{\x1b[0m%}".runes()
	return byteslc.string()
}