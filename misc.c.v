module main

fn getcurrentusername() string {
	return unsafe {cstring_to_vstring(C.getlogin())}
}