module TestSet

using Folds
using Test
include("utils.jl")

@testset begin
    @test Folds.unique(x for x in 1:100 if x < 3) ==ₜ [1, 2]
    @test Folds.unique(x for x in 1:100 if x < 3; basesize = 1) ==ₜ [1, 2]
end

end  # module
