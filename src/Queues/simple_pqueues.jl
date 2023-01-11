abstract type Priority end
#
struct PriorityDFS{T<:Real} <: Priority
    depth::Int #priority as mini sets of priority queues
    bound::T
    neg_idx::Int # the negative backtrack index (negative because of maximizing)
end

function Base.isless(p1::PriorityDFS, p2::PriorityDFS)
    if p1.depth < p2.depth  #check depth
        return true
    elseif p1.depth == p2.depth #check with unique backtrack node id
        if p1.bound < p2.bound #check bound
            return true
        elseif p1.bound == p2.bound
            return p1.neg_idx < p2.neg_idx #check unique id
        else
            return false
        end
    end
    return false
end