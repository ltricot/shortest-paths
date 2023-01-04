using Base: Base, Iterators


mutable struct Buckets{T} <: PriorityQueue
    # assumptions:
    # - monotonically increasing priorities
    # - at all times, max-priority - min-priority <= u

    arr::Vector{Vector{T}}
    cur::Int
    u::Int

    function Buckets(::Type{T}, u::Int) where {T}
        arr = [Vector() for _ in 1:(1+u)]
        new{T}(arr, 0, (1 + u))
    end
end

function enqueue!(b::Buckets{T}, priority::Int, value::T) where {T}
    Base.push!(b.arr[1+(priority%b.u)], value)
end

function dequeue!(b::Buckets)
    # it is incorrect to call dequeue when the queue is empty
    # and will result in an infinite loop :)
    for cur in Iterators.countfrom(b.cur)
        if !isempty(b.arr[1+mod(cur, b.u)])
            b.cur = cur
            return pop!(b.arr[1+mod(cur, b.u)])
        end
    end
end

function Base.isempty(b::Buckets)
    for cur in b.cur:(b.cur+b.u-1)
        if !isempty(b.arr[1+mod(cur, b.u)])
            return false
        end
    end
    return true
end
