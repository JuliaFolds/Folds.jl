    Folds.reduce(op, collection; [init] [executor_options...])
    Folds.reduce(op, collection, executor; [init])

Reduce a `collection` with an associative operator. Parallel by default.

Given a `collection` with elements `x₁`, `x₂`, ..., `xₙ`, and an associative
operator `⊗`, `Folds.reduce(⊗, collection)` computes

    x₁ ⊗ x₂ ⊗ x₃ ⊗ x₄ ⊗ ... ⊗ xₙ

If no `executor` is specified, `executor_options` are passed to the default
executor for `collection`.

# Extended help

If no executor is specified, an appropriate executor is chosen automatically
based on `collection` (e.g., `CUDAEx` for `CuArrays` if FoldsCUDA.jl is
loaded) assuming that the reduction can be parallelized; i.e.,:

1. iteration over `collection` and evaluation of`op` are **data race-free**,
2. binary function `op` is (at least approximately) **associative** and
   `init` behaves as the identity of `op`.

For example, consider

    Folds.reduce(op, (f(x) for x in xs if p(x))

The first assumption indicates that `Folds.reduce` requires that `op`, `f`,
`p`, and `iterate` on `xs` do not have any data races. For example, a
stateless function is safe to use. If these functions need to access shared
state that can be mutated while invoking `Folds.reduce`, it must be protected
using, e.g., lock or atomic. Note that, for a good performance, it is
recommended to restructure the code to avoid requiring locks in these
functions.

The second point indicates that `Folds.reduce` requires `op` to be
associative on the set of all values that `f` can produce. The default
executor and many other executors do not require exact associativity for
deterministic result, provided that scheduling parameters (e.g., `basesize`)
are configured. For example, `Folds.reduce(+, floats, ThreadedEx(); init =
0.0)` may produce slightly different result when `julia` is started wih
different number of threads. For a deterministic result independent of the
number of threads in `julia`, use `ThreadedEx(basesize = ...)` where `...` is
a large enough number. Different executor may require different properties of
`op` (e.g., exact associativity, commutativity); check the documentation of
the executor for more information.

The default executor is chosen based on `collection`. If `collection` is an
iterator transformed from another iterator, the innermost iterator is used
for determining the executor. Consider the following values for `collection`:

    xs
    (f(x) for x in xs)
    (f(x) for x in xs if p(x))

In all cases, `xs` determines the executor to be used. Thus, the reduction

    xs :: CuArray
    Folds.reduce(+, (f(x) for x in xs if p(x)))

uses `CUDAEx` executor if FoldsCUDA.jl is loaded. If `collection` is a `zip`
or `Iterators.product`, `Folds.reduce` tries to find an appropriate executor
using a promotion mechanism.

It is safe for the operator `op` to mutate of the _first_ argument if
[`Transducers.OnInit`](https://juliafolds.github.io/Transducers.jl/dev/reference/manual/#Transducers.OnInit)
is used for `init`. It can be used to create mutable accumulators (the object
passed to the first argument to `op`) that can be mutated without a data
race. Since the second argument to `op` can be originated from `collection`
or another output of `op`, mutating it can lead to unpredictable side-effects
although it may not be a problem in some cases (e.g., `collection` would be
thrown away after this computation).
