var documenterSearchIndex = {"docs":
[{"location":"#Folds.jl","page":"Folds.jl","title":"Folds.jl","text":"","category":"section"},{"location":"","page":"Folds.jl","title":"Folds.jl","text":"Modules = [Folds]","category":"page"},{"location":"#Folds.Folds","page":"Folds.jl","title":"Folds.Folds","text":"Folds: sequential, threaded, and distributed fold interface for Julia\n\n(Image: Stable) (Image: Dev) (Image: GitHub Actions)\n\nNOTE: For information on the released version, please see https://juliafolds.github.io/Folds.jl/stable\n\nFolds.jl provides a unified interface for sequential, threaded, and distributed folds.\n\njulia> using Folds\n\njulia> Folds.sum(1:10)\n55\n\njulia> Folds.sum(1:10, ThreadedEx())  # equivalent to above\n55\n\njulia> Folds.sum(1:10, DistributedEx())\n55\n\n\n\n\n\n","category":"module"},{"location":"#Folds.collect","page":"Folds.jl","title":"Folds.collect","text":"Folds.collect(collection; [init] [executor_options...]) :: AbstractArray\nFolds.collect(collection, executor; [init]) :: AbstractArray\n\n\n\n\n\n","category":"function"},{"location":"#Folds.map","page":"Folds.jl","title":"Folds.map","text":"Folds.map(f, collections...; [executor_options...])\nFolds.map(f, collections..., executor)\n\n\n\n\n\n","category":"function"},{"location":"#Folds.mapreduce","page":"Folds.jl","title":"Folds.mapreduce","text":"Folds.mapreduce(f, op, collections...; [init] [executor_options...])\nFolds.mapreduce(f, op, collections..., executor; [init])\n\n\n\n\n\n","category":"function"},{"location":"#Folds.reduce","page":"Folds.jl","title":"Folds.reduce","text":"Folds.reduce(op, collection; [init] [executor_options...])\nFolds.reduce(op, collection, executor; [init])\n\n\n\n\n\n","category":"function"},{"location":"#Folds.sum","page":"Folds.jl","title":"Folds.sum","text":"Folds.sum([f,] collection; [init] [executor_options...])\nFolds.sum([f,] collection, executor; [init])\n\n\n\n\n\n","category":"function"}]
}