module IdlePlanetMinerTools

include("things.jl")
include("arithmetic.jl")
include("recipie.jl")
include("extract_crafted.jl")

ALL_RECIPIES = make_crafted_recipies()

end
