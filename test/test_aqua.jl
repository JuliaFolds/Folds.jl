module TestAqua

import Aqua
import Folds
using Test

# Default `Aqua.test_all(Folds)` does not work due to ambiguities
# in upstream packages.

@testset "Method ambiguity" begin
    Aqua.test_ambiguities(Folds)
end

Aqua.test_all(Folds; ambiguities = false)

@testset "Compare test/Project.toml and test/environments/main/Project.toml" begin
    @test Text(read(joinpath(@__DIR__, "Project.toml"), String)) ==
          Text(read(joinpath(@__DIR__, "environments", "main", "Project.toml"), String))
end

end  # module
