using Distributed: nprocs, @everywhere
using Folds
using Test
using Transducers: DistributedEx  # TODO: stop special-casing
using Transducers: SequentialEx

down(xs) = collect(xs)
down(xs::AbstractDict) = Dict(xs)
down(xs::AbstractSet) = Set(xs)

mapbottom(f, itr) = f(itr)

function mapbottom(f, itr::Base.Generator)
    ys = f(itr.iter)
    ys === nothing && return nothing
    return Base.Generator(itr.f, ys)
end

function mapbottom(f, itr::Iterators.Filter)
    ys = f(itr.itr)
    ys === nothing && return nothing
    return Iterators.Filter(itr.flt, ys)
end

function mapbottom(f, itr::Iterators.Flatten)
    ys = f(itr.it)
    ys === nothing && return nothing
    return Iterators.flatten(ys)
end

function mapbottom(f, itr::Tuple)
    ys = map(f, itr)::Tuple
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
all(isodd(x) for x in 1:10)                                        # nogpu,FIXME
all(isodd(x) for x in 1:2:10)                                      # nogpu,FIXME
any(isodd(x) for x in 1:10)                                        # nogpu,FIXME
any(isodd(x) for x in 2:2:10)                                      # nogpu,FIXME
count(isodd(x) for x in 1:10)
extrema((x - 5)^2 for x in 1:10)
findall(isodd, 1:10)                                        # nogpu,nodist,FIXME
findfirst(x -> x > 3, 1:10)                                 # nogpu,nodist,FIXME
findlast(x -> x < 3, 1:10)                                  # nogpu,nodist,FIXME
map(x -> x^2, 1:10)                                                # nogpu,FIXME
map(+, 1:10, 11:20)                                         # nogpu,nodist,FIXME
map(+, 1:10, 11:20, 21:30)                                  # nogpu,nodist,FIXME
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
prod(([x -x; -x x] for x in 1:2:19))                                     # nogpu
prod(y for x in 1:11 if isodd(x) for y in 1:x:x^2; init = 1)
sum(1:10)
sum([1:10; [missing]])
sum(x^2 for x in 1:11)
sum(x^2 for x in 1:11 if isodd(x); init = 0)
unique(gcd(x, 42) for x in 1:30)                                         # nogpu
issorted([1:5; 5:-1:0])                                     # nogpu,nodist,FIXME
issorted(1:10)                                              # nogpu,nodist,FIXME
"""
#=
issorted(x^2 for x in 1:10)
issorted(x^2 for x in 1:10 if isodd(x))
=#

args_and_kwargs(args...; kwargs...) =
    (preargs = args[1:end-1], data = args[end], kwargs = (; kwargs...))

function parse_rawdata()
    global TESTCASES_WITH_SEQUENTIAL_DEFAULT =
        map(split(TESTCASES_WITH_SEQUENTIAL_RAWDATA, "\n", keepempty = false)) do x
            @debug "Parsing: $x"
            fstr, rest = split(x, "(", limit = 2)
            ex = Meta.parse("DUMMY($rest")
            ex.args[1] = args_and_kwargs
            testcase = @eval $ex
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

parse_rawdata()

always(_) = true

function testcases_with_sequential(; upload = identity, include_test = always)
    tests = deepcopy(TESTCASES_WITH_SEQUENTIAL_DEFAULT)
    tests = filter(include_test, tests)
    tests = map(tests) do ex
        (; ex..., data = mapbottom(upload, ex.data))
    end
    tests = filter(ex -> ex.data !== nothing, tests)
    return tests
end

test_with_sequential(executors; kwargs...) =
    test_with_sequential(testcases_with_sequential(; kwargs...), executors)

function test_with_sequential(tests, executors)
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

function test_uses_threads(fold, ex)
    if Threads.nthreads() == 1
        error("require `Threads.nthreads() > 1`")
    end
    ids = fold(vcat, ([Threads.threadid()] for _ in 1:2*Threads.nthreads()), ex)
    @test length(Set(ids)) > 1
end

function test_uses_processes(fold, ex)
    if nprocs() == 1
        error("require `nprocs() > 1`")
    end
    load_me_everywhere()
    ids = fold(vcat, ([getpid()] for _ in 1:2*nprocs()), ex)
    @test length(Set(ids)) > 1
end

function load_me_everywhere()
    pkgid = Base.PkgId(@__MODULE__)
    @everywhere Base.require($pkgid)
end
