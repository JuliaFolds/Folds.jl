module TestUsesProcesses
using Folds
using Folds.Testing: test_uses_processes
VERSION < v"1.8-" && # workaround the hang in CI
test_uses_processes(DistributedEx())
end  # module
