module TestFold

using Folds
using Test

@testset for kw in [
    NamedTuple(),
    (sequential = true,),
    (threaded = true,),
    (threaded = true, basesize = 1),
    (distributed = true,),
    (distributed = true, basesize = 1),
    (distributed = true, threaded = false),
    (distributed = true, threaded = false, basesize = 1),
]
    @test fold(+, 1:10; kw...) == 55
    if !get(kw, :distributed, false)
        @test fold(+, (x^2 for x in 1:10 if isodd(x)); kw...) == 165
    end
end

@testset for _fold in [Folds.foldl, Folds.reduce]
    @test _fold(+, 1:10) == 55
    @test _fold(+, (x^2 for x in 1:10 if isodd(x))) == 165
end

end  # module
