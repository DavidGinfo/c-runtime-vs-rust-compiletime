fn main() {
    let reference;

    {
        let value = 5;
        reference = &value;
    }

    println!("{}", reference);
}
