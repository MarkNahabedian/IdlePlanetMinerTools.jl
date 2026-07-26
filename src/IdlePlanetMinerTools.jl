module IdlePlanetMinerTools

include("modifiers.jl")
include("things.jl")
include("inventory.jl")
include("arithmetic.jl")
include("projects.jl")
include("recipie.jl")
include("extract_ores.jl")
include("extract_alloys.jl")
include("extract_crafted.jl")
include("crafting.jl")

ALL_RECIPIES = [
    make_alloy_recipies()...,
    make_crafted_recipies()...,
]

include("extract_projects.jl")
include("extract_rooms.jl")

end
