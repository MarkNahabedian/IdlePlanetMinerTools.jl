
export Project, prerequisites, next_projects

"""
Project represents an Idle Planet Miner project.
"""
abstract type Project <: Modifier end


project_ingredient_scalar(::Modifier) = 1

ingredient_scalar_function(::Type{<:Project}) = project_ingredient_scalar


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


