module main

import os
import time

struct ColorRune {
mut:
	bg int
	fg int
	text rune
}

interface Segment {
	getrunes() []ColorRune
}

fn main() {
	mut segs :=[]Segment{}
	segs << Username{}
	segs << Hostname{}
	segs << Cwd{}
	segs << PromptEnd{}
	mut joined_segs := []ColorRune{}
	for seg in segs {
		joined_segs.joincrs(seg.getrunes())
	}
	println(joined_segs.terminate().output_zsh())
}