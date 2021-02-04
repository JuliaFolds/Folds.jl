module TestAutoExecutors

using Folds
using Folds.Testing: TESTCASES_WITH_SEQUENTIAL_DEFAULT, getlabel, getdata, getequality
using Test

@testset "$(getlabel(x))" for x in enumerate(TESTCASES_WITH_SEQUENTIAL_DEFAULT)
    _, testcase = x
    ==′ = getequality(x)
    f(args...) = testcase.f(testcase.preargs..., args...; testcase.kwargs...)
    xs0 = getdata(x)
    xs1 = getdata(x)
    @test f(xs1) ==′ f(xs0, SequentialEx())
end

end  # module
