function Folds.reduce(op, itr, ex::Executor; init = FoldsInit)
    result = Transducers.fold(op, itr, ex; init = init)
    result isa FoldsInitOf && return reduce_empty(op, eltype(itr))
    return result
end

Folds.reduce(op, itr; init = FoldsInit, kwargs...) =
    Folds.reduce(op, itr, parallel_executor(bottom_foldable(itr); kwargs...); init = init)

Folds.mapreduce(f::F, op::OP, itr; init = FoldsInit, kwargs...) where {F,OP} =
    Folds.mapreduce(
        f,
        op,
        itr,
        parallel_executor(bottom_foldable(itr); kwargs...);
        init = init,
    )

function Folds.mapreduce(
    f::F,
    op::OP,
    itr,
    ex::Executor;
    init = FoldsInit,
) where {F,OP}
    result = Transducers.fold(op, itr |> Map(f), ex; init = init)
    result isa FoldsInitOf && return mapreduce_empty(f, op, eltype(itr))
    return result
end

mapreduce_check_no_kwargs(::NamedTuple{(),Tuple{}}) = nothing
@noinline function mapreduce_check_no_kwargs(kwargs)
    error(
        "`mapreduce(f, op, itrs..., executor)` only accepts `init` as keyword argument" *
        "\ngot:" *
        string(kwargs),
    )
end

function Folds.mapreduce(f, op, itr, itrs...; init = FoldsInit, kwargs...)
    args0, ex0 = de_snoc(itr, itrs...)
    if ex0 isa Executor
        xs = zip(args0...)
        ex = ex0
        mapreduce_check_no_kwargs((; kwargs...))
    else
        xs = zip(itr, itrs...)
        ex = parallel_executor(bottom_foldable(xs); kwargs...)
    end
    result = Transducers.fold(op, xs |> MapSplat(f), ex; init = init)
    result isa FoldsInitOf && return mapreduce_empty(f, op, eltype(xs))
    return result
end

@def_monoid return_nothing
@inline return_nothing(_) = nothing
@inline return_nothing(_, _) = nothing

foreach_check_no_kwargs(::NamedTuple{(),Tuple{}}) = nothing
@noinline function foreach_check_no_kwargs(kwargs)
    error(
        "`foreach(f, itrs..., executor)` accepts no keyword arguments" *
        "\ngot:" *
        string(kwargs),
    )
end

foreach_check_referenceables(_, _) = nothing
@noinline function foreach_check_referenceables(::DistributedEx, args)
    error(
        "`foreach(f, itrs..., ::DistributedEx)` is used with a referenceable. " *
        "Currently, this is not supported as the mutation will not be reflected " *
        "to the original collection."
    )
end

function Folds.foreach(f, itr, itrs...; kwargs...)
    args0, ex0 = de_snoc(itr, itrs...)
    if ex0 isa Executor
        xs = zip(args0...)
        ex = ex0
        foreach_check_no_kwargs((; kwargs...))
        Baselet.Specialized.any(isreferenceable, args0) &&
            foreach_check_referenceables(ex, args0)
    else
        xs = zip(itr, itrs...)
        ex = parallel_executor(bottom_foldable(xs); kwargs...)
    end
    transduce(MapSplat(f), return_nothing, nothing, xs, ex)
    return
end

function Folds.map!(f, dest, array, arrays...; kwargs...)
    Folds.foreach(referenceable(dest), array, arrays...; kwargs...) do y, xs...
        Base.@_inline_meta
        y[] = f(xs...)
    end
    return dest
end

"""
    ReducerFunctionAndFoldable

Reducer function with one or two arguments plus executor.
This function provides the following signature:

    reducer([f,] itr; init, executor_options...)
    reducer([f,] itr, exec; init)
"""
ReducerFunctionAndFoldable

function monoid_for end
default_init_for(reducer) = FoldsInit
default_simd_for(reducer) = Val(true)

"""
    exec(reducer, executor, f, itr, init)
"""
function exec(reducer, ex, f, itr, init)
    return Folds.mapreduce(
        f,
        monoid_for(reducer),
        itr,
        maybe_set_simd(ex, default_simd_for(reducer));
        init = default_to(init, default_init_for(reducer)),
    )
end

(reducer::ReducerFunctionAndFoldable)(itr; kwargs...) = reducer(identity, itr; kwargs...)
(reducer::ReducerFunctionAndFoldable)(f::F, itr; init = unspecified, kwargs...) where {F} =
    exec(reducer, parallel_executor(itr; kwargs...), f, itr, init)

(reducer::ReducerFunctionAndFoldable)(
    f::F,
    itr,
    ex::Executor;
    init = unspecified,
) where {F} = exec(reducer, ex, f, itr, init)

(reducer::ReducerFunctionAndFoldable)(itr, ex::Executor; init = unspecified) =
    exec(reducer, ex, identity, itr, init)

"""
    typeof(Folds.X :: Type{<:ReducerFunctionAndFoldable})
    typeof(Folds.X)

Equivalent to typeof(Folds.X)
"""
reducer_typeof
struct ReducerTypeGetter end
const reducer_typeof = ReducerTypeGetter()
function Base.getproperty(::ReducerTypeGetter, name::Symbol)
    f = getproperty(Folds, name)
    return typeof(f)::ReducerFunctionAndFoldable
end

monoid_for(::typeof(Folds.sum)) = add_sum
monoid_for(::typeof(Folds.prod)) = mul_prod
monoid_for(::typeof(Folds.maximum)) = max
monoid_for(::typeof(Folds.minimum)) = min

asbool(f) = x -> f(x)::Bool

default_init_for(::typeof(Folds.count)) = 0
exec(::typeof(Folds.count), ex, f, itr, init) =
    Folds.sum(ConvertTo(Int) ∘ asbool(f), itr, ex; init = init)
# TODO: Use `ConverTo(typeof(init))` if `init` is a "concrete" initial value.

# TODO: `any` and `all` should be done with "unordered" version
exec(::typeof(Folds.any), ex, f, itr, init) = Transducers.fold(
    right,  # no need to use `|`
    itr |> Map(asbool(f)) |> ReduceIf(identity),
    maybe_set_simd(ex, Val(true));
    init = default_to(init, false),
)

exec(::typeof(Folds.all), ex, f, itr, init) = Transducers.fold(
    right,  # no need to use `&`
    itr |> Map(asbool(f)) |> ReduceIf(!),
    maybe_set_simd(ex, Val(true));
    init = default_to(init, true),
)

exec(::typeof(Folds.findfirst), ex, f, array::AbstractArray, init) = Transducers.fold(
    right,
    pairs(array) |> ReduceIf(((i, x),) -> f(x)) |> Map(first),
    maybe_set_simd(ex, Val(true));
    init = default_to(init, nothing),
)

exec(::typeof(Folds.findlast), ex, f, array::AbstractArray, init) = Transducers.fold(
    right,
    Iterators.reverse(pairs(array)) |> ReduceIf(((i, x),) -> f(x)) |> Map(first),
    maybe_set_simd(ex, Val(true));
    init = default_to(init, nothing),
)

function exec(::typeof(Folds.findall), ex, f, array::AbstractArray, init)
    idxs = Folds.collect(pairs(array) |> Filter(((i, x),) -> f(x)) |> Map(first), ex)
    isempty(idxs) && return keytype(array)[]
    return idxs
end

_minmax((min0, max0), (min1, max1)) = (min(min0, min1), max(max0, max1))

exec(::typeof(Folds.extrema), ex, f, itr, init) = Transducers.fold(
    asmonoid(_minmax),
    itr |> Map(x -> (y = f(x); (y, y))),
    maybe_set_simd(ex, Val(true));
    init = default_to(init, DefaultInit),
)

struct PushUnique{F} <: Function
    f::F
end
PushUnique(::Type{T}) where {T} = PushUnique{Type{T}}(T)

function (f!::PushUnique)((ys, seen), x)
    fx = f!.f(x)
    return fx in seen ? (ys, seen) : (push!!(ys, x), push!!(seen, fx))
end

# TODO: do this with public API of Transducers or make it public
function Transducers.combine(f!::PushUnique, (ys1, seen1), (ys2, seen2))
    seen3 = setdiff!!(seen2, seen1)
    isempty(seen3) && return (ys1, seen1)
    return (append!!(Filter(x -> f!.f(x) in seen3), ys1, ys2), union!!(seen1, seen2))
end
# * Add an option to avoid re-compute `f(x)` in combine?
# * Iterate over `seen3` if `length(seen3) << length(ys2)`?

# Manually create a singleton callable since closure captures the
# types as `DataType` and causes type-instability:
struct InitUnique{X,Y} <: Function end
@inline function (::InitUnique{X,Y})() where {X,Y}
    if isbitstype(Y) || Base.isbitsunion(Y)
        return (X[], Set{Y}())
    else
        return (X[], Empty(Set))
    end
end

function exec(::typeof(Folds.unique), ex, f::F, itr, init) where {F}
    if Base.IteratorEltype(itr) isa Base.HasEltype
        X = eltype(itr)
    else
        X = Union{}
    end
    # Using inference as an optimization. The result of this inference
    # does not affect the returned value:
    Y = infer_eltype(f(x) for x in itr)
    ys, = Transducers.fold(PushUnique(f), itr, ex; init = OnInit(InitUnique{X,Y}()))
    if Base.IteratorEltype(itr) isa Base.HasEltype
        return ys::Vector{X}
    else
        return ys::Vector
    end
end

Folds.issorted(
    itr;
    lt = isless,
    by = identity,
    rev::Union{Bool,Nothing} = nothing,
    order::Base.Ordering = Base.Forward,
    kwargs...,
) = Folds.issorted(itr, Base.ord(lt, by, rev, order); kwargs...)

Folds.issorted(
    itr,
    ex::Executor;
    lt = isless,
    by = identity,
    rev::Union{Bool,Nothing} = nothing,
    order::Base.Ordering = Base.Forward,
    kwargs...,
) = Folds.issorted(itr, Base.ord(lt, by, rev, order), ex)

Folds.issorted(itr, order::Base.Ordering; kwargs...) =
    Folds.issorted(itr, order, parallel_executor(bottom_foldable(itr); kwargs...))

function make_geq(order)
    @inline geq((x1, x2),) = !Base.lt(order, x2, x1)
    return geq
end

#=
Folds.issorted(itr, order::Base.Ordering, ex::Executor) =
    Folds.all(make_geq(order), itr |> Consecutive(Val(2), Val(1)), ex)
=#

# TODO: check if using `zip` for arrays is better
Folds.issorted(itr::AbstractArray, order::Base.Ordering, ex::Executor) = Folds.all(
    make_geq(order),
    zip(
        view(itr, firstindex(itr):lastindex(itr)-1),
        view(itr, firstindex(itr)+1:lastindex(itr)),
    ),
    ex,
)
