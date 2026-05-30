// Ownership Rule 1
let buffer_owner = Box::new(42);

// Ownership Rule 2
let buffer_owner = Box::new(42);
let another_buffer_owner = buffer_owner;

// Ownership Rule 3
{
    let buffer_owner = Box::new(42);
}

// Stack Copy Data
let var1 = 42;
let var2 = var1;

// Borrowing and References
fn increment(value: &mut i32) {
    *value += 1;
}

fn main() {
    let mut var_pointer = Box::new(42);

    increment(&mut var_pointer);
}

// Lifetimes and Borrow Checker
fn main() {
    let reference;

    {
        let value = 5;
        rerference = &value;
    }

    println!("{}", rerference);
}
