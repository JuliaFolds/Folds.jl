const BoolFlag = Union{Bool,Val{true},Val{false}}

_asval(x::Val) = x
_asval(x) = Val(x)
_flagof(::Val{x}) where {x} = x
_flagof(x) = x
