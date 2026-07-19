module IdlePlanetMinerTools

include("things.jl")
include("inventory.jl")
include("arithmetic.jl")
include("recipie.jl")
include("extract_crafted.jl")
include("crafting.jl")

ALL_RECIPIES = make_crafted_recipies()

end
