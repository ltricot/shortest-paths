# generate erdos renyi graph
function erdos_renyi(n::Int, p::Float64)
    fw = [Vector{Tuple{Node,Int}}() for _ in 1:n]
    for i in 1:n
        for j in 1:n
            if i == j
                continue
            end
            if rand() <= p
                push!(fw[i], (j, 1))
            end
        end
    end
    return Graph(fw)
end

# watts strogatz graph
function watts_strogatz(n::Int, k::Int, p::Float64)
    fw = [Vector{Tuple{Node,Int}}() for _ in 1:n]
    for i in 1:n
        for j in 1:k
            push!(fw[i], (((i - 1 + j) % n) + 1, 1))
        end
    end
    for i in 1:n
        for j in 1:k
            if rand() <= p
                # pick random node
                dst = 0
                while true
                    dst = rand(1:n)
                    if dst != i
                        break
                    end
                end
                # remove old edge
                for (idx, (dst_, _)) in enumerate(fw[i])
                    if dst_ == (((i - 1 + j) % n) + 1)
                        deleteat!(fw[i], idx)
                        break
                    end
                end
                # add new edge
                push!(fw[i], (dst, 1))
            end
        end
    end
    return Graph(fw)
end

# barabasi albert graph
function barabasi_albert(n::Int, m::Int)
    fw = [Vector{Tuple{Node,Int}}() for _ in 1:n]
    for i in 1:n
        for j in 1:m
            push!(fw[i], (j, 1))
        end
    end
    for i in (m+1):n
        # pick m random nodes
        nodes = Set{Node}()
        while length(nodes) < m
            push!(nodes, rand(1:i-1))
        end
        for node in nodes
            push!(fw[i], (node, 1))
        end
    end
    return Graph(fw)
end

# eppstein power law graph
function eppstein_power_law(n::Int, alpha::Float64)
    fw = [Vector{Tuple{Node,Int}}() for _ in 1:n]
    for i in 1:n
        for j in 1:n
            if i == j
                continue
            end
            if rand() <= (j / (i + j))^alpha
                push!(fw[i], (j, 1))
            end
        end
    end
    return Graph(fw)
end
