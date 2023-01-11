using Base: Iterators


struct Auction <: ShortestPathAlgorithm end


function presort!(g::Graph)
    for adj in Iterators.flatten((fw(g), bw(g)))
        sort!(adj, by=t -> t[2])
    end
end

function _auction(g::Graph{W}, s::Node, t::Node) where {W<:Integer}
    path = [s]
    prices = [zero(W) for _ in fw(g)]

    while (i = path[end]) != t
        (lb, j), _ = findmin(fw(g)[i]) do (j, w)
            (w + prices[j], j)
        end

        if prices[i] < lb
            prices[i] = lb
            if i != s
                pop!(path)
            end
        else
            push!(path, j)
        end
    end

    true, prices[s], path
end

function sp(::Type{Auction}, g::Graph{W}, s::Node, t::Node) where {W<:Integer}
    _, _, path = _auction(g, s, t)
    path
end