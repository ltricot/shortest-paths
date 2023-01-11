include("Queues/Queues.jl")
using .Queues


abstract type BucketsAlgorithm <: ShortestPathAlgorithm end

struct LabelSettingHeap <: ShortestPathAlgorithm end
struct LabelSettingBidiHeap <: ShortestPathAlgorithm end

struct LabelSettingBuckets <: BucketsAlgorithm end
struct LabelSettingBidiBuckets <: BucketsAlgorithm end


function _label_setting_generic(g::Graph{W}, s::Node, S::H) where {W,H<:PriorityQueue}
    L = fill(typemax(W), length(fw(g)))
    P = fill(zero(Node), length(fw(g)))
    seen = 0

    enqueue!(S, zero(W), (zero(W), s, s))
    while !isempty(S) && seen < length(fw(g))
        cost, node, pred = dequeue!(S)
        if L[node] <= cost
            continue
        end

        seen += 1
        P[node] = pred
        L[node] = cost

        for (adjacent, weight) in fw(g)[node]
            if L[adjacent] > cost + weight
                enqueue!(S, cost + weight, (cost + weight, adjacent, node))
            end
        end
    end

    P
end

function _label_setting_generic(g::Graph{W}, s::Node, t::Node, S::H) where {W,H<:PriorityQueue}
    L = fill(typemax(W), length(fw(g)))
    P = fill(zero(Node), length(fw(g)))

    enqueue!(S, zero(W), (zero(W), s, s))
    while !isempty(S)
        cost, node, pred = dequeue!(S)
        if L[node] <= cost
            continue
        end

        P[node] = pred
        L[node] = cost

        if node == t
            break
        else
            for (adjacent, weight) in fw(g)[node]
                if L[adjacent] > cost + weight
                    enqueue!(S, cost + weight, (cost + weight, adjacent, node))
                end
            end
        end
    end

    P
end

function sp(::Type{LabelSettingHeap}, g::Graph{W}, s::Node) where {W}
    _label_setting_generic(g, s, Heap(W, Tuple{W,Node,Node}))
end

function sp(::Type{LabelSettingBuckets}, u::W, g::Graph{W}, s::Node) where {W<:Integer}
    _label_setting_generic(g, s, Buckets(Tuple{W,Node,Node}, u))
end

function _path(parent::Vector{Node}, s::Node, t::Node)
    path = [t]
    while path[end] != s
        push!(path, parent[path[end]])
    end
    reverse!(path)
end

function sp(::Type{LabelSettingHeap}, g::Graph{W}, s::Node, t::Node) where {W}
    P = _label_setting_generic(g, s, t, Heap(W, Tuple{W,Node,Node}))
    if P[t] != 0
        _path(P, s, t)
    end
end

function sp(::Type{LabelSettingBuckets}, u::W, g::Graph{W}, s::Node, t::Node) where {W<:Integer}
    P = _label_setting_generic(g, s, t, Buckets(Tuple{W,Node,Node}, u))
    if P[t] != 0
        _path(P, s, t)
    end
end

function _bidirectional_label_setting_generic(g::Graph{W}, s::Node, t::Node, SF::H, SB::H) where {W,H<:PriorityQueue}
    LF = fill(typemax(W), length(fw(g)))
    LB = fill(typemax(W), length(fw(g)))
    PF = fill(zero(Node) - 1, length(fw(g)))
    PB = fill(zero(Node) - 1, length(fw(g)))

    enqueue!(SF, zero(W), (zero(W), s, s))
    enqueue!(SB, zero(W), (zero(W), t, t))

    beta = typemax(W)
    v, w = s, t
    while !isempty(SF) && !isempty(SB)
        costF, nodeF, predF = dequeue!(SF)
        costB, nodeB, predB = dequeue!(SB)

        if LF[nodeF] > costF
            LF[nodeF] = costF
            PF[nodeF] = predF

            for (adjacent, weight) in fw(g)[nodeF]
                if LF[adjacent] > costF + weight
                    enqueue!(SF, costF + weight, (costF + weight, adjacent, nodeF))
                    if LB[adjacent] < typemax(W) && costF + LB[adjacent] + weight < beta
                        beta = costF + LB[adjacent] + weight
                        v, w = nodeF, adjacent
                    end
                end
            end
        end

        if LB[nodeB] > costB
            LB[nodeB] = costB
            PB[nodeB] = predB

            for (adjacent, weight) in bw(g)[nodeB]
                if LB[adjacent] > costB + weight
                    enqueue!(SB, costB + weight, (costB + weight, adjacent, nodeB))
                    if LF[adjacent] < typemax(W) && costB + LF[adjacent] + weight < beta
                        beta = costB + LF[adjacent] + weight
                        v, w = adjacent, nodeB
                    end
                end
            end
        end

        if LF[nodeB] < typemax(W) && LB[nodeF] < typemax(W)
            if s == t  # unfortunate special case
                beta = 0
                v, w = s, s
            end

            return true, v, w, PF, PB
        end
    end

    return false, v, w, PF, PB
end

function sp(::Type{LabelSettingBidiHeap}, g::Graph{W}, s::Node, t::Node) where {W}
    found, v, w, PF, PB = _bidirectional_label_setting_generic(g, s, t, Heap(W, Tuple{W,Node,Node}), Heap(W, Tuple{W,Node,Node}))
    if found
        path = _path(PF, s, v)
        if v != w
            push!(path, w)
        end
        while path[end] != t
            push!(path, PB[path[end]])
        end
        return path
    end
end

function sp(::Type{LabelSettingBidiBuckets}, u::W, g::Graph{W}, s::Node, t::Node) where {W<:Integer}
    found, v, w, PF, PB = _bidirectional_label_setting_generic(g, s, t, Buckets(Tuple{W,Node,Node}, u), Buckets(Tuple{W,Node,Node}, u))
    if found
        path = _path(PF, s, v)
        if v != w
            push!(path, w)
        end
        while path[end] != t
            push!(path, PB[path[end]])
        end
        return path
    end
end