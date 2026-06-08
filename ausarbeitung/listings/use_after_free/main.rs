fn main() {
    let buffer_owner = Box::new(42);

    let buffer_borrow = &buffer_owner;

    drop(buffer_owner);

    println!("{}", buffer_borrow);
}
