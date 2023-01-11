using Test

include("../src/Queues/Queues.jl")
using .Queues

include("../src/NSSP.jl")
using .NSSP


function grid(n::Int, u::Int)
    fw = Vector{Vector{Tuple{Node,Int}}}()

    function ok(i::Int, j::Int, n::Int)
        0 <= i < n && 0 <= j < n
    end

    for k in 0:(n*n-1)
        i, j = divrem(k, n)

        adj = Vector{Tuple{Node,Int}}()
        for (ni, nj) in [(i - 1, j), (i + 1, j), (i, j - 1), (i, j + 1)]
            if ok(ni, nj, n)
                push!(adj, (1 + n * ni + nj, rand(1:u)))
            end
        end

        push!(fw, adj)
    end

    AdjListGraph(fw)
end

function path(P::Vector{Node}, s::Node, t::Node)
    path = [t]
    while path[end] != s
        push!(path, P[path[end]])
    end
    reverse!(path)
    path
end

function pcost(g::Graph{W}, path::Vector{Node}) where {W}
    c = zero(W)
    for (u, v) in zip(path[1:end-1], path[2:end])
        c += fw(g)[u][findfirst(x -> x[1] == v, fw(g)[u])][2]
    end
    c
end

function istree(P::Vector{Node}, s::Node)
    visited = falses(length(P))
    visited[s] = true

    # take one node and follow the path to the root
    # check for a cycle while doing so
    # mark all nodes in the path visited
    # start over with the next unvisited node
    for u in 1:length(P)
        if !visited[u]
            v = u
            while !visited[v]
                visited[v] = true
                v = P[v]
            end

            # none of u's children can be visited, so that if
            # there is a cycle, v must be u
            if v == u
                return false
            end
        end
    end

    true
end

function path(P::Vector{Node}, s::Node, t::Node)
    path = [t]
    while path[end] != s
        push!(path, P[path[end]])
    end
    reverse!(path)
    path
end


@testset "Single Source Single Destination" verbose = true begin
    @testset "Source = Destination" begin
        n, u = 10, 10
        g = grid(n, u)

        for s in 1:n*n
            t = s
            c1 = pcost(g, sp(LabelSettingHeap, g, s, t))
            c2 = pcost(g, sp(LabelSettingBuckets, u, g, s, t))
            c3 = pcost(g, sp(LabelSettingBidiHeap, g, s, t))
            c4 = pcost(g, sp(LabelSettingBidiBuckets, u, g, s, t))
            c5 = pcost(g, sp(Auction, g, s, t))

            @test c1 == c2 == c3 == c4 == c5 == 0
        end
    end

    @testset "Small and exhaustive" begin
        n, u = 3, 10
        g = grid(n, u)

        for s in 1:n*n, t in 1:n*n
            c1 = pcost(g, sp(LabelSettingHeap, g, s, t))
            c2 = pcost(g, sp(LabelSettingBuckets, u, g, s, t))
            c3 = pcost(g, sp(LabelSettingBidiHeap, g, s, t))
            c4 = pcost(g, sp(LabelSettingBidiBuckets, u, g, s, t))
            c5 = pcost(g, sp(Auction, g, s, t))

            @test c1 == c2 == c3 == c4 == c5
        end
    end

    @testset "Large and randomized" begin
        n, u = 30, 100
        g = grid(n, u)

        for _ in 1:50
            s = rand(1:n*n)
            t = rand(1:n*n)

            c1 = pcost(g, sp(LabelSettingHeap, g, s, t))
            c2 = pcost(g, sp(LabelSettingBuckets, u, g, s, t))
            c3 = pcost(g, sp(LabelSettingBidiHeap, g, s, t))
            c4 = pcost(g, sp(LabelSettingBidiBuckets, u, g, s, t))
            c5 = pcost(g, sp(Auction, g, s, t))

            @test c1 == c2 == c3 == c4 == c5
        end
    end
end

@testset "Single Source All Destinations" verbose = true begin
    @testset "Small and exhaustive" begin
        n, u = 10, 10
        g = grid(n, u)

        for s in 1:n*n
            p1 = sp(LabelSettingHeap, g, s)
            p2 = sp(LabelSettingBuckets, u, g, s)
            p3 = sp(LabelCorrecting, g, s)
            p4 = sp(Simplex, g, s)

            @test istree(p1, s)
            @test istree(p2, s)
            @test istree(p3, s)
            @test istree(p4, s)

            for t in 1:n*n
                c1 = pcost(g, path(p1, s, t))
                c2 = pcost(g, path(p2, s, t))
                c3 = pcost(g, path(p3, s, t))
                c4 = pcost(g, path(p4, s, t))

                @test c1 == c2 == c3 == c4
            end
        end
    end

    @testset "Large and randomized" begin
        n, u = 30, 1000
        g = grid(n, u)

        for s in 1:100
            p1 = sp(LabelSettingHeap, g, s)
            p2 = sp(LabelSettingBuckets, u, g, s)
            p3 = sp(Simplex, g, s)

            @test istree(p1, s)
            @test istree(p2, s)
            @test istree(p3, s)

            for t in 1:n*n
                c1 = pcost(g, path(p1, s, t))
                c2 = pcost(g, path(p2, s, t))
                c3 = pcost(g, path(p3, s, t))

                @test c1 == c2 == c3
            end
        end
    end
end

# test heap implementation with random data
@testset "Heap" begin
    h = Heap(Int, Tuple{Int,Int})
    enqueue!(h, 5, (5, 5))
    enqueue!(h, 3, (3, 3))
    enqueue!(h, 4, (4, 4))
    enqueue!(h, 1, (1, 1))
    enqueue!(h, 2, (2, 2))
    @test dequeue!(h) == (1, 1)
    @test dequeue!(h) == (2, 2)
    @test dequeue!(h) == (3, 3)
    @test dequeue!(h) == (4, 4)
    @test dequeue!(h) == (5, 5)
end

# test buckets implementation with random data
@testset "Buckets" begin
    b = Buckets(Tuple{Int,Int}, 5)
    enqueue!(b, 5, (5, 5))
    enqueue!(b, 3, (3, 3))
    enqueue!(b, 4, (4, 4))
    enqueue!(b, 1, (1, 1))
    enqueue!(b, 2, (2, 2))
    @test dequeue!(b) == (1, 1)
    @test dequeue!(b) == (2, 2)
    @test dequeue!(b) == (3, 3)
    @test dequeue!(b) == (4, 4)
    @test dequeue!(b) == (5, 5)
end
