
export Project, prerequisites, next_projects, add_researched_project

"""
Project represents an Idle Planet Miner project.
"""
abstract type Project <: Modifier end


"""
    prerequisites(::Type{<:Project})

Returns a vector of the immediate prerequisites that are required
before researching the specified `Project`.
"""
prerequisites(::Type{<:Project}) = []


"""
    next_projects(modifiers=DEFAULT_MODIFIERS)

Assuming that the projects in `modifiers` have already been
researches, what are the next projects to be researches?
"""
function next_projects(modifiers=DEFAULT_MODIFIERS)
    have_projects = map(typeof, filter(m -> m isa Project, modifiers))
    next = []
    for p in subtypes(Project)
        if !isempty(intersect(have_projects, prerequisites(p)))
            if !in(p, have_projects) && !in(p, next)
                push!(next, p)
            end
        end
    end
    next
end


"""
    add_researched_project(add_this::Project, to::Vector{Modifier}=DEFAULT_MODIFIERS)

Add `add_this` and the transitive closure of its prerequisites to `to`
if they are not already present.
"""
function add_researched_project(add_this::Type{<:Project},
                                to::Vector{<:Modifier}=DEFAULT_MODIFIERS)
    to_types = map(typeof, filter(x -> x isa Project, to))
    function add1(add_this)
        if add_this in to_types
            return
        end
        push!(to, add_this())
        for pr in prerequisites(add_this)
            add1(pr)
        end
    end
    add1(add_this)
    to
end

