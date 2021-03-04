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
DefineSingletons.@def_singleton prod isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton sum isa Core.ReducerFunctionAndFoldable
DefineSingletons.@def_singleton unique isa Core.ReducerFunctionAndFoldable

function issorted end

function set end
function dict end

module Implementations
using Base: HasShape, IteratorSize

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
using Baselet: Baselet
using MicroCollections: emptyshim, singletonshim
using Base: add_sum, mul_prod, mapreduce_empty
using DefineSingletons: @def_singleton
using InitialValues: @def_monoid, InitialValue, asmonoid
using Referenceables: isreferenceable, referenceable
using Transducers:
    Consecutive,
    DefaultInit,
    DistributedEx,
    Executor,
    Filter,
    IdentityTransducer,
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
    right,
    tcollect,
    transduce,
    unreduced,
    wheninit

using ..Folds.Core: ReducerFunctionAndFoldable
using ..Folds: Folds

include("utils.jl")
include("reduce.jl")
include("collect.jl")
include("misc.jl")
end

module Testing
include("testing.jl")
end

Implementations.define_docstrings()

end
