module IdlePlanetMinerTools

include("modifiers.jl")
include("things.jl")
include("inventory.jl")
include("arithmetic.jl")

abstract type Project end

"""
    prerequisites(::Project)

Returns a Vector of the prerequsite Projects of the Project.
"""
prerequisites(::Project)::Vector[<:Project]  = []


include("recipie.jl")
include("extract_crafted.jl")
include("crafting.jl")

ALL_RECIPIES = make_crafted_recipies()


include("extract_projects.jl")


end
