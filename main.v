module main

import os

struct ColorRune {
mut:
	bg int
	fg int
	text rune
}

interface Segment {
	getrunes() []ColorRune
}

struct C.winsize {
pub:
    ws_row u16
    ws_col u16
    ws_xpixel u16
    ws_ypixel u16
}

fn main() {
	if "--dumpcache" in os.args {
		println(dump_cache())
		exit(0)
	}

	// segment part 1!!
	mut segs := []Segment{cap: 3}
	segs << Username{}
	segs << Hostname{}
	segs << Cwd{}
	mut joined_segs := []ColorRune{cap: colorrune_cap_large}
	for seg in segs {
		joined_segs.joincrs(seg.getrunes())
	}
	joined_segs = joined_segs.terminate()

	// fill between segment!
	mut wsize := C.winsize{}
	fd := C.open('/dev/tty'.str, C.O_RDONLY)
	C.ioctl(fd, C.TIOCGWINSZ, &wsize);
	joined_segs.fill_until(wsize.ws_col, ColorRune{bg: 0, fg:0, text: ` `})

	// right segments!!
	mut segs_right :=	[]Segment{cap: 2}
	mut leftcr := []ColorRune{cap: colorrune_cap_mid}
	mut langver := LangVersion{}

	langver.lvc.get_version()
	segs_right << langver

	segs_right << Git{}
	for seg in segs_right {
		leftcr.joincrs_right(seg.getrunes())
	}
	leftcr = leftcr.terminate_right()
	joined_segs.draw_right(leftcr)

	// segment part 2!!
	mut second_segs := []Segment{cap: 1}
	second_segs << PromptEnd{}
	for seg in second_segs {
		joined_segs.joincrs(seg.getrunes())
	}
	joined_segs = joined_segs.terminate()

	mut stdout := os.stdout()
	os.fd_write(stdout.fd, joined_segs.output_zsh())
	//println(joined_segs.output_zsh())
	exit(0)
}