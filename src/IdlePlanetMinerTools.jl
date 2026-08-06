module IdlePlanetMinerTools

include("modifiers.jl")
include("things.jl")
include("inventory.jl")
include("arithmetic.jl")
include("projects.jl")
include("processes.jl")
include("recipie.jl")
include("extraction_tools.jl")
include("extract_ores.jl")
include("extract_alloys.jl")
include("extract_crafted.jl")
include("crafting.jl")

include_dependency(joinpath(@__DIR__, "ores.csv"))
include_dependency(joinpath(@__DIR__, "alloys.csv"))
include_dependency(joinpath(@__DIR__, "crafted.csv"))
make_ore_definitions()
make_alloy_definitions()
make_crafted_recipies()

@assert 1 == minimum(ordinal, subtypes(Ore))
@assert maximum(ordinal, subtypes(Ore)) + 1 == minimum(ordinal, subtypes(Alloy))
@assert maximum(ordinal, subtypes(Alloy)) + 1 == minimum(ordinal, subtypes(Crafted))
@assert 1:99 == sort(map(ordinal, union([ subtypes(x) for x in subtypes(Thing) ]...)))

include("extract_projects.jl")
include("extract_rooms.jl")
include("extract_planets.jl")

# make_planet_definitions()

end
