fn main() {
    let buffer_owner = Box::new(42);

    let buffer_borrow = &buffer_owner;

    drop(buffer_owner); 

    println!("{}", buffer_borrow);
}

// error[E0505]: cannot move out of `buffer_owner` because it is borrowed
//  --> src/main.rs:6:10
//   |
// 2 |     let buffer_owner = Box::new(42);
//   |         ------------ binding `buffer_owner` declared here
// 3 |
// 4 |     let buffer_borrow = &buffer_owner;
//   |                         ------------- borrow of `buffer_owner` occurs here
// 5 |
// 6 |     drop(buffer_owner); 
//   |          ^^^^^^^^^^^^ move out of `buffer_owner` occurs here
// 7 |
// 8 |     println!("{}", buffer_borrow);
//   |                    ------------- borrow later used here
//   |
// help: consider cloning the value if the performance cost is acceptable
//   |
// 4 |     let buffer_borrow = &buffer_owner.clone();
//   |                                      ++++++++

// For more information about this error, try `rustc --explain E0505`.