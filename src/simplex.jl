struct Simplex <: ShortestPathAlgorithm end


function _bfs(g::Graph{W}, s::Node) where {W<:Number}
    prices = fill(zero(W), length(g.fw))
    fw = [Vector{Tuple{Node,W}}() for _ in g.fw]

    seen = falses(length(g.fw))
    seen[s] = true

    queue = [(s, 0)]
    while !isempty(queue)
        u, c = popfirst!(queue)
        prices[u] = c
        for (v, w) in g.fw[u]
            if !seen[v]
                seen[v] = true
                push!(fw[u], (v, w))
                push!(queue, (v, c + w))
            end
        end
    end

    Graph(fw), prices
end

function _update_prices(T::Graph, prices, u, v, w)
    stack = [(u, v, w)]
    while !isempty(stack)
        u, v, w = pop!(stack)
        prices[v] = prices[u] + w

        for (n, w) in T.fw[v]
            push!(stack, (v, n, w))
        end
    end
end

function _pivot(T::Graph{W}, prices, u::Node, v::Node, w::W) where {W}
    p, _ = T.bw[v][1]
    T.bw[v][1] = (u, w)
    push!(T.fw[u], (v, w))
    T.fw[p] = filter(x -> x[1] != v, T.fw[p])
    _update_prices(T, prices, u, v, w)
end

function _simplex(g::Graph{W}, s::Node) where {W}
    T, prices = _bfs(g, s)

    while true
        pivoted = false
        for u in eachindex(g.fw), (v, w) in g.fw[u]
            if w - prices[v] + prices[u] < 0
                _pivot(T, prices, u, v, w)
                pivoted = true
            end
        end

        if !pivoted
            break
        end
    end

    return T, prices
end

function sp(::Type{Simplex}, g::Graph{W}, s::Node) where {W<:Number}
    T, _ = _simplex(g, s)

    P = fill(zero(Node), length(g.fw))
    for (v, bw) in enumerate(T.bw)
        if length(bw) > 0
            u, _ = bw[1]
            P[v] = u
        end
    end

    P
end