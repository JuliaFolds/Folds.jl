Folds.collect(itr; kwargs...) = Folds.collect(itr, parallel_executor(itr; kwargs...))

function Folds.collect(itr, ex::Executor)
    acc =
        transduce(Map(SingletonVector), wheninit(collector, append!!), collector(), itr, ex)
    return reshape_as(finish!(unreduced(acc)), itr)
end

Folds.collect(itr, ex::PreferParallel) = Folds.collect(itr, executor_for(itr, ex))
Folds.collect(itr, ex::SequentialEx) =
    reshape_as(collect(extract_transducer(itr)...; ex.kwargs...), itr)
Folds.collect(itr, ex::ThreadedEx) =
    reshape_as(tcollect(extract_transducer(itr)...; ex.kwargs...), itr)
Folds.collect(itr, ex::DistributedEx) =
    reshape_as(dcollect(extract_transducer(itr)...; ex.kwargs...), itr)

reshape_as(ys, xs) = reshape_as(ys, xs, IteratorSize(xs))
reshape_as(ys, _, ::IteratorSize) = ys
reshape_as(ys, xs, ::HasShape) = reshape(ys, size(xs))
reshape_as(::Empty{T}, xs, isize::HasShape) where {T<:AbstractVector} =
    reshape_as(T(undef, length(xs)), xs, isize)

function as_copy_args(T, itr)
    xf, coll = extract_transducer(itr)
    return (xf, T, coll)
end

Folds.copy(T, itr; kwargs...) = Folds.copy(T, itr, parallel_executor(itr; kwargs...))

Folds.copy(T, itr, ex::SequentialEx) = copy(as_copy_args(T, itr)...; ex.kwargs...)

# TODO: implement `copy(itr, ex)`; move materializer to here

Folds.copy(T, itr, ex::Executor) = copy_default(T, itr, ex)

copy_default(T, itr, ex) =
    Folds.reduce(append!!, itr |> Map(SingletonVector), ex; init = Empty(T))

struct SingletonShimOf{T} end
(::SingletonShimOf{T})(x) where {T} = singletonshim(T, x)

function copy_default(T::Type{<:AbstractSet}, itr, ex)
    xf, array = extract_transducer(itr)
    if xf isa Union{Map{identity},IdentityTransducer}
        if array isa PartitionableArray
            basesize =
                something(get_basesize(ex), max(1, length(array) ÷ Threads.nthreads()))
            return Folds.reduce(
                union!!,
                Iterators.partition(array, basesize),
                set_basesize(ex, 1);
                init = Empty(T),
            )
        end
    end
    return Folds.reduce(union!!, itr |> Map(SingletonVector), ex; init = Empty(T))
end

struct Unpairs{Data}
    data::Data
end

Base.pairs(pairs::Unpairs) = pairs.data

function copy_default(T::Type{<:AbstractDict}, itr, ex)
    xf, array = extract_transducer(itr)
    if xf isa Union{Map{identity},IdentityTransducer}
        if array isa PartitionableArray
            isempty(array) && return T(array)
            basesize =
                something(get_basesize(ex), max(1, length(array) ÷ Threads.nthreads()))
            return Folds.reduce(
                merge!!,
                Iterators.partition(array, basesize) |> Map(Unpairs),
                set_basesize(ex, 1);
                init = emptyshim(T),
            )
        end
    end
    return Folds.reduce(merge!!, itr |> Map(SingletonShimOf{T}()), ex; init = emptyshim(T))
end

Folds.map(f, itr; kwargs...) = Folds.collect(itr |> Map(f), parallel_executor(itr; kwargs...))
Folds.map(f, itr, ex::Executor) = Folds.collect(itr |> Map(f), ex)

map_check_no_kwargs(::NamedTuple{(),Tuple{}}) = nothing
@noinline function map_check_no_kwargs(kwargs)
    error(
        "`map(f, itrs..., executor)` does not accept any keyword arguments" *
        "\ngot:" *
        string(kwargs),
    )
end

function Folds.map(f, itr, itrs...; kwargs...)
    args0, ex0 = de_snoc(itr, itrs...)
    if ex0 isa Executor
        xs = zip(args0...)
        ex = ex0
        map_check_no_kwargs((; kwargs...))
    else
        xs = zip(itr, itrs...)
        ex = parallel_executor(bottom_foldable(xs); kwargs...)
    end
    return Folds.collect(xs |> MapSplat(f), ex)
end

# TODO: use `Folds.copy(AbstractSet, ...)`?
Folds.set(itr; kwargs...) = Folds.copy(Set, itr; kwargs...)
Folds.set(itr, ex; kwargs...) = Folds.copy(Set, itr, ex; kwargs...)

# TODO: use `Folds.copy(AbstractDict, ...)`?
Folds.dict(itr; kwargs...) = Folds.copy(Dict, itr; kwargs...)
Folds.dict(itr, ex; kwargs...) = Folds.copy(Dict, itr, ex; kwargs...)
