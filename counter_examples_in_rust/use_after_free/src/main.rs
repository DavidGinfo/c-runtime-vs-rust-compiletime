fn main() {
    const BUFFER_SIZE: usize = 512;

    let buffer1 = String::with_capacity(BUFFER_SIZE);

    drop(buffer1);

    let mut buffer2 = String::with_capacity(BUFFER_SIZE);

    buffer2.push_str("blubb");

    println!("{}", buffer1);
}
