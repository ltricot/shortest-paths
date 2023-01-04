module Queues
include("common.jl")
include("fourheap.jl")
include("linearbuckets.jl")

export PriorityQueue, Heap, Buckets, enqueue!, dequeue!

end
