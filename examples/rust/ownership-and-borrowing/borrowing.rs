fn increment(value: &mut i32) {
    *value += 1;
}

fn main() {
    let mut var_pointer = Box::new(42);
    increment(&mut var_pointer);
}
