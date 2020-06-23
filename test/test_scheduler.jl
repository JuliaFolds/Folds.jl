module TestScheduler

using Folds: Scheduler
using Folds.Implementations: Distributed, Sequential, Threaded, ThreadedUnordered
using Test

macro test_inferred(ex)
    function fixln(x)
        x isa LineNumberNode && return __source__
        x isa Expr || return x
        return Expr(x.head, map(fixln, x.args)...)
    end
    quote
        f() = $(esc(ex))
        Test.@test Test.@inferred(f()) isa Any
    end |> fixln
end

@testset "inference" begin
    @test_inferred Scheduler()
    if VERSION >= v"1.5-beta1"
        @test_inferred Scheduler(distributed = true)
        @test_inferred Scheduler(threaded = true)
        @test_inferred Scheduler(threaded = true, ordered = false)
        @test_inferred Scheduler(sequential = true)
    end
end

@testset "type" begin
    @test Scheduler() isa Scheduler
    @test Scheduler(distributed = true) isa Distributed
    @test Scheduler(threaded = true) isa Threaded
    @test Scheduler(threaded = true, ordered = false) isa ThreadedUnordered
    @test Scheduler(sequential = true) isa Sequential
end

end  # module
