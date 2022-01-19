using Distributed: nprocs, @everywhere
using Folds
using Test
using Transducers: DistributedEx  # TODO: stop special-casing
using Transducers: Eduction, SequentialEx, extract_transducer

const Comprehension = Union{
    Iterators.Generator,
    Iterators.Filter,
    Iterators.Flatten,
}

function down(xs::Union{Eduction,Comprehension})
    xf, foldable = extract_transducer(xs)
    return xf(down(foldable))
end

down(xs) = collect(xs)
down(xs::AbstractDict) = Dict(xs)
down(xs::AbstractSet) = Set(xs)

mapbottom(f, itr) = f(itr)

function mapbottom(f, itr::Base.Generator)
    ys = mapbottom(f, itr.iter)
    ys === nothing && return nothing
    return Base.Generator(itr.f, ys)
end

function mapbottom(f, itr::Iterators.Filter)
    ys = mapbottom(f, itr.itr)
    ys === nothing && return nothing
    return Iterators.Filter(itr.flt, ys)
end

function mapbottom(f, itr::Iterators.Flatten)
    ys = mapbottom(f, itr.it)
    ys === nothing && return nothing
    return Iterators.flatten(ys)
end

function mapbottom(f, itr::Tuple)
    ys = map(x -> mapbottom(f, x), itr)::Tuple
    any(isnothing, ys) && return nothing
    return ys
end

function getlabel((i, example),)
    if example isa NamedTuple
        return example.label
    else
        return "$i"
    end
end

function getdata((_, example),)
    if example isa NamedTuple
        return example.data
    else
        return example
    end
end

function getequality((_, example),)
    if example isa NamedTuple && haskey(example, :eq)
        return example.eq
    else
        return isequal
    end
end

macro data_str(s)
    data = include_string(__module__, s)
    return (label = s, data = data)
end

TESTCASES_WITH_SEQUENTIAL_RAWDATA = """
all(isodd(x) for x in 1:10)
all(isodd(x) for x in 1:2:10)
any(isodd(x) for x in 1:10)
any(isodd(x) for x in 2:2:10)
copy(Set, 1:10)                                                   # nodist,FIXME
copy(Set, Dict(zip('a':'j', 1:10)))                               # nodist,FIXME
copy(Dict, (x => x^2 for x in 1:10))
copy(Dict, (x => x^2 for x in Set(1:10)))                         # nodist,FIXME
copy(Vector, 1:10)
count(isodd(x) for x in 1:10)
dict(x => x^2 for x in 1:10)
extrema((x - 5)^2 for x in 1:10)
findall(isodd, 1:10)                                              # nodist,FIXME
findfirst(x -> x > 3, 1:10)                                       # nodist,FIXME
findlast(x -> x < 3, 1:10)                                        # nodist,FIXME
map(x -> x^2, 1:10)
map(+, 1:10, 11:20)                                               # nodist,FIXME
map(+, 1:10, 11:20, 21:30)                                        # nodist,FIXME
mapreduce(identity, +, 1:0)
mapreduce(x -> x^2, +, 1:10)
mapreduce(*, +, 1:10, 11:20)                                      # nodist,FIXME
mapreduce(*, +, 1:10, 11:20, 21:30)                               # nodist,FIXME
maximum(0:9)
maximum(9:-1:0)
maximum([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
maximum([1:10; [missing]])
minimum(0:9)
minimum(9:-1:0)
minimum([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
minimum([1:10; [missing]])
prod(1:2:10)
prod([1:10; [missing]])
prod(([x -x; -x x] for x in 1:2:19))
prod(y for x in 1:11 if isodd(x) for y in 1:x:x^2; init = 1)
reduce(+, 1:0)
set(1:10)                                                         # nodist,FIXME
set(x^2 for x in 1:10)
sum(1:10)
sum([1:10; [missing]])
sum(x^2 for x in 1:11)
sum(x^2 for x in 1:11 if isodd(x); init = 0)
unique(gcd(x, 42) for x in 1:30)
unique(x for x in 1:100 if x < 3)
issorted([1:5; 5:-1:0])                                           # nodist,FIXME
issorted(1:10)                                                    # nodist,FIXME
"""
#=
issorted(x^2 for x in 1:10)
issorted(x^2 for x in 1:10 if isodd(x))
=#

TESTCASES_WITH_SEQUENTIAL_RAWDATA_JL17 = """
findmax(0:9)                                                      # nodist,FIXME
findmax(9:-1:0)                                                   # nodist,FIXME
findmax([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])                           # nodist,FIXME
findmax([1:10; [missing]])                                        # nodist,FIXME
findmin(0:9)                                                      # nodist,FIXME
findmin(9:-1:0)                                                   # nodist,FIXME
findmin([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])                           # nodist,FIXME
findmin([1:10; [missing]])                                        # nodist,FIXME
argmax(0:9)                                                       # nodist,FIXME
argmax(9:-1:0)                                                    # nodist,FIXME
argmax([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])                            # nodist,FIXME
argmax([1:10; [missing]])                                         # nodist,FIXME
argmin(0:9)                                                       # nodist,FIXME
argmin(9:-1:0)                                                    # nodist,FIXME
argmin(x -> x^2, [2, 3, 0, 3, 4, 0, 5, 7, 4, 2])                  # nodist,FIXME
argmin(x -> x^2, [1:10; [missing]])                               # nodist,FIXME
argmax(x -> x^2, 0:9)                                             # nodist,FIXME
argmax(x -> x^2, 9:-1:0)                                          # nodist,FIXME
argmax(x -> x^2, [2, 3, 0, 3, 4, 0, 5, 7, 4, 2])                  # nodist,FIXME
argmax(x -> x^2, [1:10; [missing]])                               # nodist,FIXME
argmin(x -> x^2, 0:9)                                             # nodist,FIXME
argmin(x -> x^2, 9:-1:0)                                          # nodist,FIXME
argmin(x -> x^2, [2, 3, 0, 3, 4, 0, 5, 7, 4, 2])                  # nodist,FIXME
argmin(x -> x^2, [1:10; [missing]])                               # nodist,FIXME
"""

args_and_kwargs(args...; kwargs...) =
    (preargs = args[1:end-1], data = args[end], kwargs = (; kwargs...))

function parse_tests(str, _module)
    return map(split(str, "\n", keepempty = false)) do x
        @debug "Parsing: $x"
        fstr, rest = split(x, "(", limit = 2)
        ex = Meta.parse("DUMMY($rest")
        ex.args[1] = args_and_kwargs
        testcase = Base.eval(_module, ex)
        f = getproperty(Folds, Symbol(fstr))
        if (m = match(r"^(.*?) *# *(.*?) *$", x)) !== nothing
            label = m[1]
            tags = map(Symbol, split(m[2], ","))
        else
            label = x
            tags = Symbol[]
        end
        return (; label = label, tags = tags, f = f, testcase...)
    end
end

function _eval_collection_data(str, _module)
    return map(split(str, "\n", keepempty = false)) do x
        if (m = match(r"^(.*?) *# *(.*?) *$", x)) !== nothing
            label = m[1]
            tags = map(Symbol, split(m[2], ","))
        else
            label = x
            tags = Symbol[]
        end
        (label = label, data = Base.include_string(_module, x), tags = tags)
    end
end

eval_call_data(str, preamble::Union{Expr,Nothing} = nothing) =
    _eval_data(parse_tests, str, preamble)

eval_collection_data(str, preamble::Union{Expr,Nothing} = nothing) =
    _eval_data(_eval_collection_data, str, preamble)

function _eval_data(f, str, preamble)
    load_me_everywhere()
    @gensym folds_testing
    preamble = QuoteNode(preamble)
    _module = QuoteNode(folds_testing)
    @everywhere $_remote_eval_data($f, $str, $preamble, $_module)
    return getfield(getfield(Main, folds_testing), :DATA)
end

function _remote_eval_data(f, str, preamble, _module)
    @eval Main module $_module
        $preamble
        const DATA = $f($str, $_module)
    end
end

function _reeval()
    global TESTCASES_WITH_SEQUENTIAL_DEFAULT =
        parse_tests(TESTCASES_WITH_SEQUENTIAL_RAWDATA, @__MODULE__)
    if VERSION ≥ v"1.7"
        append!(
            TESTCASES_WITH_SEQUENTIAL_DEFAULT,
            parse_tests(TESTCASES_WITH_SEQUENTIAL_RAWDATA_JL17, @__MODULE__),
        )
    end
end

_reeval()

always(_) = true

function testcases_with_sequential(tests; upload = identity, include_test = always)
    tests = deepcopy(tests)
    tests = filter(include_test, tests)
    tests = map(tests) do ex
        (; ex..., data = mapbottom(upload, ex.data))
    end
    tests = filter(ex -> ex.data !== nothing, tests)
    return tests
end

test_with_sequential(executors; kwargs...) =
    test_with_sequential(TESTCASES_WITH_SEQUENTIAL_DEFAULT, executors; kwargs...)

function test_with_sequential(tests, executors; kwargs...)
    tests = testcases_with_sequential(tests; kwargs...)
    @testset "$(getlabel(x))" for x in enumerate(tests)
        @debug "test_with_sequential $(getlabel(x))"
        i, testcase = x
        f(args...) = testcase.f(testcase.preargs..., args...; testcase.kwargs...)
        ==′ = getequality(x)
        @testset "$ex" for ex in executors
            @debug "test_with_sequential $(getlabel(x)) $ex"
            :nodist in testcase.tags && ex isa DistributedEx && continue
            xs0 = down(getdata(x))
            xs1 = getdata(x)
            @test f(xs1, ex) ==′ f(xs0, SequentialEx())
        end
    end
end

function spinfor(d)
    limit = time_ns() + d
    while limit > time_ns()
        ccall(:jl_cpu_pause, Cvoid, ())
    end
end

function test_uses_threads(ex)
    @testset "test_uses_threads" begin
        if Threads.nthreads() == 1
            error("require `Threads.nthreads() > 1`")
        else
            ids = Folds.map(1:2*Threads.nthreads(), ex) do _
                spinfor(1000_000)
                Threads.threadid()
            end
            @test length(Set(ids)) > 1
        end
    end
end

is_ci() = get(ENV, "CI", "false") == "true"

function test_uses_processes(ex; autoskip = !is_ci())
    @testset "test_uses_processes" begin
        if nprocs() == 1
            if autoskip
                @warn """
                Skipping `test_uses_processes` since there is no Distributed workers.
                Run the test with environment variable `CI` set to `true` to run this test.
                """
            else
                error("require `nprocs() > 1`")
            end
        else
            load_me_everywhere()
            ids = Folds.map(1:2*nprocs(), ex) do _
                getpid()
            end
            @test length(Set(ids)) > 1
        end
    end
end

function load_me_everywhere()
    pkgid = Base.PkgId(@__MODULE__)
    @everywhere Base.require($pkgid)
end
