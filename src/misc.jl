function Base.print(io::IO, f::ReducerFunctionAndFoldable)
    show(IOContext(io, :limit => false), f)
end

function Base.show(io::IO, ::MIME"text/plain", f::ReducerFunctionAndFoldable)
    n = length(methods(f))
    m = n > 1 ? "methods" : "method"
    print(io, f)
    print(io, " (generic function with $n $m)")
end
