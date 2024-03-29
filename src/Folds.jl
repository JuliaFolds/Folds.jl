baremodule Folds

export DistributedEx, SequentialEx, ThreadedEx

using Transducers: DistributedEx, SequentialEx, ThreadedEx

module Core
abstract type ReducerFunctionAndFoldable <: Function end
end

import DefineSingletons

function reduce end
function mapreduce end
function foreach end
function collect end
function copy end
function map end
function map! end

DefineSingletons.@def_singleton all isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton any isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton count isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton extrema isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton findall isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton findfirst isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton findlast isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton maximum isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton minimum isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton findmax isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton findmin isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton prod isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton sum isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton unique isa Core.ReducerFunctionAndFoldable

function argmax end
function argmin end

function issorted end

function cumsum end
function cumsum! end
function cumprod end
function cumprod! end
function accumulate end
function accumulate! end
function scan! end

function set end
function dict end

module Implementations

import ThreadedScans

using Accessors: @set
using BangBang:
    Empty,
    SingletonVector,
    append!!,
    collector,
    finish!,
    push!!,
    union!!,
    merge!!,
    setdiff!!
using Base: HasShape, IteratorSize, add_sum, mapreduce_empty, mul_prod, reduce_empty
using Baselet: Baselet
using DefineSingletons: @def_singleton
using ExternalDocstrings: @define_docstrings
using InitialValues: @def_monoid, SpecificInitialValue, asmonoid
using MicroCollections: emptyshim, singletonshim
using Referenceables: isreferenceable, referenceable
using Requires: @require
using Transducers:
    Consecutive,
    DefaultInit,
    DistributedEx,
    Executor,
    Filter,
    IdentityTransducer,
    InitOf,
    Map,
    MapSplat,
    OnInit,
    PreferParallel,
    ReduceIf,
    SequentialEx,
    ThreadedEx,
    Transducers,
    dcollect,
    executor_for,
    extract_transducer,
    maybe_set_simd,
    reducingfunction,
    right,
    tcollect,
    transduce,
    unreduced,
    wheninit

using ..Folds.Core: ReducerFunctionAndFoldable
using ..Folds: Folds

include("utils.jl")
include("reduce.jl")
include("scan.jl")
include("collect.jl")
include("misc.jl")

function __init__()
    @require OnlineStatsBase="925886fa-5bf2-5e8e-b522-a9147a512338" begin
        include("interop/onlinestats.jl")
    end
end

end

module Testing
include("testing.jl")
end

Implementations.@define_docstrings

end
