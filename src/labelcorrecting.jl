struct LabelCorrecting <: ShortestPathAlgorithm end


function _bfm(g::Graph{W}, s::Node) where {W<:Number}
    n = length(g.fw)
    L = fill(typemax(W), n)
    L[s] = zero(W)
    P = fill(zero(Node), n)

    for _ in 1:n-1
        for u in 1:n
            for (v, w) in g.fw[u]
                if L[u] < typemax(W) && L[u] + w < L[v]
                    P[v] = u
                    L[v] = L[u] + w
                end
            end
        end
    end

    return P
end

function sp(::Type{LabelCorrecting}, g::Graph{W}, s::Node) where {W<:Number}
    _bfm(g, s)
end