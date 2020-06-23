module TestDoctest

import Folds
using Documenter: doctest
using Test

@testset "doctest" begin
    doctest(Folds; manual = false)
end

end  # module
