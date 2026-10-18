# Example catalog

The examples are intentionally independent files rather than one workspace. Some are
expected to fail compilation; keeping them independent makes that behavior explicit.

| Directory | Purpose | Expected result |
| --- | --- | --- |
| [`c/out-of-bounds-write`](c/out-of-bounds-write) | Write past a C array | Compiles; behavior is undefined |
| [`c/use-after-free`](c/use-after-free) | Dereference freed heap memory | Compiles; behavior is undefined |
| [`rust/out-of-bounds-write`](rust/out-of-bounds-write) | Index an array beyond its length | Compile-time rejection or runtime panic |
| [`rust/use-after-free`](rust/use-after-free) | Use a reference after moving its owner | Compile-time rejection |
| [`rust/ownership-and-borrowing`](rust/ownership-and-borrowing) | Ownership, mutable borrowing, and lifetime snippets | Teaching snippets; some are intentionally invalid |

## Running the Rust examples

```powershell
rustc examples/rust/out-of-bounds-write/main.rs -o out-of-bounds-write.exe
.\out-of-bounds-write.exe
rustc examples/rust/use-after-free/main.rs
```

The final command should fail with a borrow-checker diagnostic. To force the
compile-time check for the known invalid index:

```powershell
rustc --deny unconditional_panic examples/rust/out-of-bounds-write/main.rs
```

## Running the C examples

```powershell
cc examples/c/out-of-bounds-write/main.c -o out-of-bounds-write
cc examples/c/use-after-free/main.c -o use-after-free
```

Both programs have undefined behavior. Do not infer correctness from one observed
output; use sanitizers when experimenting:

```powershell
cc -fsanitize=address -g examples/c/use-after-free/main.c -o use-after-free
```
