# C and Rust: the same failures

The examples use the same small scenarios so the language difference is attributable
to the memory model rather than application complexity.

## Use after free

The C version allocates one integer, aliases its address, frees the allocation, and
then dereferences the stale pointer:

```c
int *buffer_ptr1 = malloc(sizeof(int));
int *buffer_ptr2 = buffer_ptr1;
free(buffer_ptr1);
printf("%d", *buffer_ptr2); // undefined behavior
```

The complete example is
[`examples/c/use-after-free/main.c`](../examples/c/use-after-free/main.c). It may
print an old value, a replacement allocation's value, or crash. None of these outcomes
is guaranteed.

The Rust version creates a borrow and then attempts to move the owner into `drop`.
`rustc` reports that the owner cannot be moved while the borrow is later used:

```rust
let owner = Box::new(42);
let borrow = &owner;
drop(owner);              // error: owner is borrowed
println!("{borrow}");
```

Run [`examples/rust/use-after-free/main.rs`](../examples/rust/use-after-free/main.rs)
to see the diagnostic. The error is produced before execution.

## Out-of-bounds write

The C array has two elements, but the program writes element `2`. C performs no
automatic bounds check:

```c
int array[2] = {2, 2};
array[2] = 99; // undefined behavior
```

The Rust equivalent uses a slice and the same invalid index. The compiler can reject
the statically known access with `unconditional_panic`; when the index is dynamic,
the generated bounds check panics at runtime.

```rust
let mut array = [2, 2];
array[2] = 99; // statically known panic
```

Compare [`examples/c/out-of-bounds-write/main.c`](../examples/c/out-of-bounds-write/main.c)
with [`examples/rust/out-of-bounds-write/main.rs`](../examples/rust/out-of-bounds-write/main.rs).

The expected Rust runtime result is a controlled panic:

```text
thread 'main' panicked at ...:
index out of bounds: the len is 2 but the index is 2
```

## What the comparison does not prove

These examples demonstrate language mechanisms, not a complete security benchmark.
They do not measure performance, prove that all Rust programs are secure, or imply
that replacing a language automatically fixes design flaws. The relevant engineering
choice is where a project places its safety proof: in manual review and runtime tools,
or in compiler-enforced invariants plus explicit review at unsafe boundaries.
