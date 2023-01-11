# Shortest Paths

## Introduction

Shortest path algorithms are quite rich. Everybody knows Dijkstra and Bellman-Ford, but they are not the end of the story:
- Dijkstra is part of the collection of _label setting_ algorithms and Bellman-Ford is part of the collection of _label correcting_ algorithms
- Dijkstra implementations have seen a lot of research: Dijkstra with a Heap is $O(N \log N + E)$ but better complexities and more performant implementations can be obtained by working with other priority queue data structures
- Bidirectional label setting is a simple idea which yields a good performance improvement
- Bertsekas introduced an auction algorithm for the shortest path which does not fit into the usual categories of shortest path algorithms
- The network simplex takes a relatively simple form when used to solve shortest path problems

Some things to work on:
- [x] More abstract graph interface without sacrificing performance: notably `g.fw` should be `fw(g)`. This would notably allow for lazy graphs, which will eventually come in handy.
- [ ] Implement random graph generators for a variety of "families" to test how robust the various algorithms are.
- [ ] Two-level, multilevel, and HOT-Queues Dijkstra implementations (these are all monotonic priority queue structures)
- [ ] Speed up the network simplex algorithm by using more appropriate data structures. Currently, updating prices is $O(N)$ and pivoting is $O(d)$ (degree)
- [ ] Speed up the auction algorithm (several papers give simple ideas to do so)
- [ ] Explore parallelism: Bertsekas claims the auction algorithm greatly benefits.
- [ ] Implement the [Landmarks](https://www.cs.princeton.edu/courses/archive/spr06/cos423/Handouts/GH05.pdf) idea introduced by Goldberg & Harrelson.
- [ ] Perhaps the idea above can be used as a warm start for the Auction algorithm: the latter is a form of dual ascent algorithm which would benefit from approximate, feasible starting prices.
- [ ] Implement other label setting algorithms like D'Esopo-Pape
- [ ] Implement the primal-dual shortest path algorithm based on the cut formulation for the shortest path problem
- [ ] Implement the primal-dual shortest path algorithm based on the min cost flow formulation
- [ ] Use the simplex algorithm to enumerate shortest paths in order of increasing lengths: this is running a shortest path algo on the graph of extremal points of the shortest path polyhedron ! I believe this has never been done before
- [ ] Implement a scaling algorithm (FPTA) to solve the constrained shortest path as a shortest path problem an an auxiliary graph (details to come)
- [ ] Implement Glover's threshold algorithm, and his [PSP algorithm](https://www-jstor-org.libproxy.mit.edu/stable/170867#metadata_info_tab_contents)

## Running the tests

```
julia test/runtests.jl
```

## Running the benchmarks

Open the `src/bench.ipynb` jupyter notebook and run all.