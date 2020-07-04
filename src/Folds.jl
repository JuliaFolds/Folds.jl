baremodule Folds

export fold

function fold end
function foldl end
function reduce end
function append! end

abstract type Scheduler end

module Implementations
using ..Folds: Folds, Scheduler
using Transducers:
    Foldable,
    IdentityTransducer,
    SIMDFlag,
    Transducer,
    dcollect,
    dreduce,
    extract_transducer,
    reduce_commutative,
    tcollect
include("utils.jl")
include("schedulers.jl")
include("core.jl")
include("reducers.jl")

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end Folds

end

end
