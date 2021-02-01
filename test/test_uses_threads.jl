module TestUsesThreads
import PerformanceTestTools
if Threads.nthreads() > 1
    include("__test_uses_threads.jl")
else
    PerformanceTestTools.@include_foreach(
        "__test_uses_threads.jl",
        [["JULIA_NUM_THREADS" => "2"]],
    )
end
end  # module
