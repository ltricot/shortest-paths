using Base: Iterators, Base


const Node = Int


# nodes are numbered from 1 to n
struct Graph{W<:Number}
    fw::Vector{Vector{Tuple{Node,W}}} # forward edges
    bw::Vector{Vector{Tuple{Node,W}}} # backward edges

    # create a graph from a list of forward edges
    function Graph(fw::Vector{Vector{Tuple{Node,W}}}) where {W<:Number}
        bw = [[] for _ in 1:length(fw)]
        for (src, adj) in enumerate(fw)
            for (dst, weight) in adj
                push!(bw[dst], (src, weight))
            end
        end

        return new{W}(fw, bw)
    end
end