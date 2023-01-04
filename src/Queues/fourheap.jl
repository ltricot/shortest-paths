using Base


# supposedly four heaps are faster than binary heaps
# I don't think it makes much of a difference in Julia
const D = 4


mutable struct Heap{W<:Number,T} <: PriorityQueue
    arr::Vector{Tuple{W,T}}

    function Heap(::Type{W}, ::Type{T}) where {W<:Number,T}
        new{W,T}(Vector{Tuple{W,T}}())
    end
end

Base.isempty(h::Heap) = Base.isempty(h.arr)

@inline function up(i::Int)
    div(i - 2, D) + 1
end

@inline function down(i::Int)
    (i - 1) * D + 2
end

function enqueue!(h::Heap{W,T}, priority::W, value::T) where {W,T}
    elem = (priority, value)
    Base.push!(h.arr, elem)
    _sift_up!(h, length(h.arr), elem)
end

function dequeue!(h::Heap)
    (_, value), last = h.arr[1], Base.pop!(h.arr)

    if length(h.arr) > 0
        _sift_down!(h, 1, last)
    end

    value
end

function _sift_up!(h::Heap{W,T}, i::Int, v::Tuple{W,T}) where {W,T}
    @inbounds while i > 1
        p = up(i)
        if h.arr[p] <= v
            break
        end

        h.arr[i] = h.arr[p]
        i = p
    end

    @inbounds h.arr[i] = v
end

function _sift_down!(h::Heap{W,T}, i::Int, v::Tuple{W,T}) where {W,T}
    @inbounds while (k = down(i)) <= length(h.arr)
        l = min(length(h.arr), k + D - 1)
        jv, j = findmin(view(h.arr, k:l))
        if jv > v
            break
        end

        h.arr[i] = jv
        i = k + j - 1
    end

    @inbounds h.arr[i] = v
end
