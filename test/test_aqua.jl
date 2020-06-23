module TestAqua

import Aqua
import Folds
using Test

# Default `Aqua.test_all(Folds)` does not work due to ambiguities
# in upstream packages.

@testset "Method ambiguity" begin
    Aqua.test_ambiguities(Folds)
end

@testset "Unbound type parameters" begin
    Aqua.test_unbound_args(Folds)
end

@testset "Undefined exports" begin
    Aqua.test_undefined_exports(Folds)
end

@testset "Compare Project.toml and test/Project.toml" begin
    Aqua.test_project_extras(Folds)
end

end  # module
