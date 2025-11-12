# How does Rust solve some of the most common bugs in modern Software?

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

### Intro: Detailed deep dive into one feature
Decide between one of the two core mechanisms with related concepts:
1. Ownership: Concept of Temporal safety
2. Borrowing & Lifetimes: Concept of Aliasing and lifetime soundness

### Feature overview

### Why it works? Theory (perhaps with partial proof)

### Practical exmaple

### Analysis and comparison to C

## Sources

### Theoretical sources

Good sources for extracting theoretical proofs why Rust's concepts work correctly.
Maybe great to pick one and break this one down.

- [Oxide: The Essence of Rust](https://arxiv.org/pdf/1903.00982) 
- [ConSORT: Context- and Flow-Sensitive Ownership Refinement Types for Imperative Programs](https://arxiv.org/pdf/2002.07770)
- [Ownership Types: A Survey](https://ilyasergey.net/papers/ownership-survey.pdf)