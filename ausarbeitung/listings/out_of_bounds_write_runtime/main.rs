fn write_slice(arr: &mut [i32], index: usize) {
    arr[index] = 99;
}

fn main() {
    let var = 5;
    let mut array = [2, 2];

    write_slice(&mut array, 2);

    println!("{}", var);
}
