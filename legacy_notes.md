# Conclusion

## Rust vs C

- [Manual vs Automated Memory Safety](https://www.ijcs.net/ijcs/index.php/ijcs/article/view/4640/1006)
- [Analysis of CVE's in Rust](https://arxiv.org/pdf/2003.03296)
- [Effectiveness in Preventing Common Vulnerabilities](https://www.sciencedirect.com/science/article/pii/S1877050923016757)

## Limits of Rust

- [Counterexamples in Safe Rust](https://web.cs.ucdavis.edu/~cdstanford/doc/2024/ASEW24a.pdf)

# How Rust prevents common Vulnerabilities in modern Software

## Intro and Motivation

Use CWE and possible other statistics which show that memory safety related bugs are the most present weakness category.

## Memory Safety

What does memory safety in general mean.

### Formal definition and categories

Give an formal explanation of memory safety and classification of bugs.

### Example: Use-After-Free

Describe issue and give and example C code.

### Example: Out-of-Bounds access

Describe issue and give and example C code.

### Soluation Approaches

- runtime checks of memory unsafe programs
- abstraction through runtime env
- compile time analysis to preserve memory safety

## Rust's Solution

Give a short introduction into Rust programming language. Also use some historical aspects.

### Basic Knowledge

Describe knowledge required to understand the main Rust features:

- Stack and Heap
- Variables Scope
- Immutability of variables

### Ownership and Borrowing

Explain ownership and borrowing as the solution for use-after-free bugs using a pracital example

### Slicing

Explain how this feature works and how it resolves the out-of-bounds access of memory using a practical example as a counterpart to the unsafe C code.

## Conclusion

Evaluate about all findings made and try to give a perspective.

### C vs Rust

Use some paper's to highlight how effective the Solution "Rust" to the typical memory safety related weaknesses in C really is. Therefore use the following metrics:
- How many CVE's are really resolved
- runtime performance
- compile times

### Limits of Rust

Use literature to demonstrate the limits of Rust.

### Outlook

Give an future perspective for the relevance of Rust

# How does Rust preserve Memory Safety?

### Stack and Heap

- Repeat the concepts of stack and heap

### Variable related Terms

### Scope and Validity
- define scope of a variable
- when is a variable valid and when invalid?

### Mutability

- what does immutable and mutable mean?
- how do now if some variable is immutable?

### Ownership Rules

- Define basic rules of ownership like they are stated in the [docu](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html)

### Copying and Move Semantics in Rust: Transferring Ownership
Discuss how one or more of the previous explained vulnaravilites in C is solved by the concepts of Rust's Ownership transferring semantics.

- Shallow Copy: Copy Trait
- Deep Copy: Clone
- Move: Standard

### Borrowing: Lack of Ownership
Discuss how one or more of the previous explained vulnaravilites in C is solved by the concepts of Rust's borrowing of references.

- access variables stored on the heap without transferring ownership: borrowing
- immutable references: only one mutable references at the same time to prevent data races
- avoidence of dangling references: lifetimes (just give an outlook)

### Slicing

- how slicing in Rust works
- how it prevents out of bounds accessing
- if there is time left: deref coercions

### Can programs written in Rust proven to be memory safe?

- why is that important?
- what does [soundness](https://iep.utm.edu/val-snd/) mean?
- first [approach](https://plv.mpi-sws.org/rustbelt/popl18/paper.pdf) to prove that a subset of Rust's programming language is memory safe

# How does Rust solve some of the most common bugs in modern Software?

## TODO

### Intro
- [X] Research about common issues in modern programs
- [X] Create overview and contents for research project
- [X] Run through the intro of Rust

### Problem definition and memory safety issues
- [ ] Do some more research about common vulnarabilites in C/C++ related to memory safety
- [ ] Give detailed explanation of memory safety
- [ ] Define categories of memory safety and give examples for the most important/common ones

### Soluation approaches
- [ ] Using tools to check memory unsafe programs during runtime
- [ ] Memory safety due to runtime environment
- [ ] Memory safety achieved at compile time

### Rust's Soluation

- [ ] Learn about Rust's intermediate features in chapter 2-11 and chapter 15
- [ ] Run through the intermediate Rust coding example
- [ ] Select one of Rust's features which is mandatory to achieve compile time memory safety
- [ ] Provide an example which solves the same problem as one of the preceding C programs does, but is memory safe
- [ ] Select a theoretical aspect of what makes Rust memory safe (keyword sound/complete proofing approaches)
- [ ] Define metrics for measuring differences between C/C++ programs and Rust

## Relevance and Background
Use statistics of CWE (Common Weakness Enumeration) from 2024 to explain why this topic is relevant today.

Besides a lot of security issues two common issues related to memory safety can be found in the top 10:
- Out-of-bounds Write (CWE-787) at Rank 1
- Use After Free (CEW-416) at Rank 9

Another statistic of the CWE says that 35% of all vulnerabilities are related to memory safety.

Of course memory safety is a problem which is solved by interpreted languages like Python or Javascript and also for languages which are not compiled to actual machine code but to Bytecode which runs in special environment.
But they all have the same disadvantages, they leak of performance.

But how is Rust solving those issues without sacraficing performance?

Sources:
- [CWE Top 10 KEV Weaknesses](https://cwe.mitre.org/top25/archive/2024/2024_kev_list.html)

## What does Memory Safety actually mean?

### General Characterization

A program is considered memory safe if all of the following conditions are met:

1. Memory which is not owned can not be accessed
2. Freed memory can not be written or read anymore
3. Occurance of dangling references or invalid pointers is not possible
4. Memory corruption can not cause undefined behaviour

### Categories and Typical Issues

- Buffer overlfow
- User-after-free
- Double free
- Dangling pointers
- Uninitialized memory

Focus on those which get later be solved by Rust's machanism's.

For all of those issues practical examples will be chosen to highlight the problems.
Valgrind or another runtime tool is used to debug/trace those issues.

### Various approaches to solutions

- Saftey by runtime design: Garbage Collection
- Memory Safety analysis during runtime for C/C++ programs: Trace bugs using Tools like Valgrind
- Statically forced memory safety: Rust

## Rust's Approach

Rust provides mechanism's so solve the errors related to memory safety during compiletime:

| Vulnerability | Rust Mechanism |
| -------- | ------- |
| Buffer overflow | Bounds checking + slices |
| User-after-free | Ownership rules |
| Double free | Drop auto-management |
| Dangling pointers | Lifetimes |
| Uninitialized memory | Definite Initialization Checking |

Evaluation of two core concepts with pracital examples and theory.

### Intro: Detailed deep dive into core feature of Rust **Ownership**
Introduction in what Ownership means in Rust.
Discuss base concepts:
- Stack vs Heap
- Basic Rust Programming Concepts
- Soundness

### Feature overview
Explain how the following methods of ownership work:

- Ownership Rules
- Borrowing
- Rerferences

### Why it works? The Theory
There is a lot of theoretical research work about the Soundness of Rust.

It could be interesting here to explain just the concepts which are used to proof such a soundness. If soundness could be fully proven, this means that it is guaranteed that Rust code can not cause undefined behaviour.

The Rust project has a lot of interesting publications about this topic. Especially this one could be interesting to understand partifularly the base concepts.

### Practical exmaple

Take one of the examples discussed in the intro and translate it to Rust.

### Analysis and comparison to C
Select some metrics for final analysis to measure:
- memory footprint
- runtime performance
- compile time

## Sources

### Theoretical sources

Good sources for extracting theoretical proofs why Rust's concepts work correctly.
Maybe great to pick one and break this one down.

- [Oxide: The Essence of Rust](https://arxiv.org/pdf/1903.00982) 
- [ConSORT: Context- and Flow-Sensitive Ownership Refinement Types for Imperative Programs](https://arxiv.org/pdf/2002.07770)
- [Ownership Types: A Survey](https://ilyasergey.net/papers/ownership-survey.pdf)
- [Rustbelt](https://plv.mpi-sws.org/rustbelt/)
- [RustBelt: Securing the Foundations of the Rust
Programming Language](https://hal.science/hal-01633165v2/document)