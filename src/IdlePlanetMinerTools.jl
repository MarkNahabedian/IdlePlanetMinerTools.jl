module IdlePlanetMinerTools

include("modifiers.jl")
include("things.jl")
include("inventory.jl")
include("arithmetic.jl")


"""
Project represents an Idle Planet Miner project.
"""
abstract type Project end


"""
    prerequisites(::Project)

Returns a Vector of the prerequsite Projects of the Project.
"""
prerequisites(::Project)::Vector[<:Project]  = []


include("recipie.jl")
include("extract_crafted.jl")
include("extract_alloys.jl")
include("crafting.jl")

ALL_RECIPIES = [
    make_alloy_recipies()...,
    make_crafted_recipies()...,
]

include("extract_projects.jl")

end
