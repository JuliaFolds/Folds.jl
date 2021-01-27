module TestTesting

using Folds.Testing: mapbottom
using Test

vinc(x::AbstractVector) = x .+ 1

@testset "mapbottom" begin
    @test collect(mapbottom(vinc, (x for x in 1:3))) == 2:4
    @test collect(mapbottom(vinc, (x for x in 1:3 if isodd(x)))) == 3:3
    @test collect(mapbottom(vinc, (y for x in (1:2, 3:4) for y in x))) == 2:5
    @test collect(mapbottom(vinc, (y for x in (1:2, 3:4) for y in x if isodd(y)))) == 3:2:5
end

end  # module
