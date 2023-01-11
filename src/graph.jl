using Base: Iterators, Base


const Node = Int

abstract type Graph{W<:Number} end


# nodes are numbered from 1 to n
struct AdjListGraph{W<:Number} <: Graph{W}
    fw::Vector{Vector{Tuple{Node,W}}} # forward edges
    bw::Vector{Vector{Tuple{Node,W}}} # backward edges

    # create a graph from a list of forward edges
    function AdjListGraph(fw::Vector{Vector{Tuple{Node,W}}}) where {W<:Number}
        bw = [[] for _ in 1:length(fw)]
        for (src, adj) in enumerate(fw)
            for (dst, weight) in adj
                push!(bw[dst], (src, weight))
            end
        end

        return new{W}(fw, bw)
    end
end

fw(g::AdjListGraph) = g.fw
bw(g::AdjListGraph) = g.bw

struct ReversedGraph{W<:Number} <: Graph{W}
    g::Graph{W}
end

fw(g::ReversedGraph) = bw(g.g)
bw(g::ReversedGraph) = fw(g.g)

Base.reverse(g::Graph) = ReversedGraph(g)