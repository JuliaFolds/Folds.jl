@def_singleton unspecified::Unspecified
default_to(value, _) = value
default_to(::Unspecified, default) = default

function bottom_foldable(itr)
    _xf, foldable = extract_transducer(itr)
    return foldable
end

without_basesize(; basesize = nothing, kw...) = kw

struct ConvertTo{T} end
@inline (::ConvertTo{T})(x) where {T} = convert(T, x)
ConvertTo(::Type{T}) where {T} = ConvertTo{T}()
# ConvertTo(::T) where {T} = ConvertTo{T}()

"""
    de_snoc(butlast..., last) -> (butlast, last)
"""
@inline function de_snoc(x, xs...)
    butlast, last = de_snoc(xs...)
    return (x, butlast...), last
end
@inline de_snoc(x) = (), x

parallel_executor(xs; kwargs...) = executor_for(xs, PreferParallel(; kwargs...))

# TODO: something like these should be in the interface
get_basesize(ex) = get(ex.kwargs, :basesize, nothing)
set_basesize(ex, basesize) = @set ex.kwargs = (; ex.kwargs..., basesize = basesize)

# https://github.com/JuliaLang/julia/pull/33533
if VERSION < v"1.4"
    const PartitionableArray = Vector
else
    const PartitionableArray = AbstractArray
end

const _SOME_BOOL_ = Ref(false)
@noinline unreachable() = error("unreachable")

function some_item(itr)
    for x in itr
        _SOME_BOOL_[] && return x
    end
    unreachable()
end

# The result of this function must not leak outside the public function boundary.
@inline infer_eltype(::T) where {T} = infer_eltype(T)
@inline infer_eltype(::Type{T}) where {T} = Core.Compiler.return_type(some_item, Tuple{T})

function define_docstrings()
    docstrings = [:Folds => joinpath(dirname(@__DIR__), "README.md")]
    docsdir = joinpath(@__DIR__, "docs")
    for filename in readdir(docsdir)
        stem, ext = splitext(filename)
        ext == ".md" || continue
        name = Symbol(stem)
        name in names(Folds, all=true) || continue
        push!(docstrings, name => joinpath(docsdir, filename))
    end
    for (name, path) in docstrings
        include_dependency(path)
        doc = read(path, String)
        doc = replace(doc, r"^```julia"m => "```jldoctest $name")
        doc = replace(doc, "<kbd>TAB</kbd>" => "_TAB_")
        @eval Folds $Base.@doc $doc $name
    end
end
