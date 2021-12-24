module TestFolds

import LoadAllPackages
using Test
using Distributed: addprocs, nworkers
using Test

if get(ENV, "CI", "false") == "true"
    VERSION < v"1.8-" && # workaround the hang in CI
    addprocs(3)

    # Tests in `PerformanceTestTools.@include_foreach` might cause
    # pre-compilation errors as two processes try to compile packages
    # at the same time.  This can happen when the tests are run via
    # `Pkg.test`.  Doing this after `addprocs` to workaround a quirk
    # in Distributed.jl.
    LoadAllPackages.loadall()
end
@info "Testing with:" nworkers()

@testset "$file" for file in sort([
    file for file in readdir(@__DIR__) if match(r"^test_.*\.jl$", file) !== nothing
])
    if file == "test_doctest.jl"
        if lowercase(get(ENV, "JULIA_PKGEVAL", "false")) == "true"
            @info "Skipping doctests on PkgEval."
            continue
        elseif VERSION >= v"1.6-"
            @info "Skipping doctests on Julia $VERSION."
            continue
        end
    end

    include(file)
end

end  # module
