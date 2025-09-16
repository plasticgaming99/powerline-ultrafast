module main

fn (mut cr []ColorRune) fill_until(num int, run ColorRune) {
	l := cr.len
	for _ in 0..num-l {
		cr << run
	}
}