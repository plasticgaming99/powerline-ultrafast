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
	mut seg :=[]Segment{}
	seg << Username{}
	seg << Hostname{}
	println(joincrs(seg[0].getrunes(), seg[1].getrunes()).output_zsh())
}