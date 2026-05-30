fn write_slice(arr: &mut [i32], index: usize) {
    arr[index] = 99; 
}

fn main() {
    let var = 5;
    let mut array = [2, 2];

    write_slice(&mut array, 2); 

    println!("{}", var); 
}

// fn main() {
//     let var = 5;
//     let mut array = [2, 2];

//     array[2] = 99;

//     println!("{}", var); 
// }

// error: this operation will panic at runtime
//  --> src/main.rs:5:5
//   |
// 5 |     array[2] = 99;
//   |     ^^^^^^^^ index out of bounds: the length is 2 but the index is 2
//   |
//   = note: `#[deny(unconditional_panic)]` on by default

// thread 'main' (12) panicked at src/main.rs:2:5:
// index out of bounds: the len is 2 but the index is 2