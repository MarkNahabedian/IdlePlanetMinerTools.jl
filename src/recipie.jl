export Recipie, ALL_RECIPIES, delta, lookup_recipie, @rx_str


"""
Recipie describes how to make Alloys, crafted items, projects, etc,
anything that required some number of [`Thing`](@ref)s.
"""
struct Recipie
    make::Union{Type{<:Thing}, Type{<:Project}}
    ingredients::Inventory
    duration_seconds::Union{Missing, Int}

    Recipie(name, ingredients::Inventory, duration_seconds) =
        new(name, ingredients, duration_seconds)
end

namestring(r::Recipie) = namestring(r.make)

ingredient_scalar_function(::Type{<:Alloy}) = smelt_ingredient_scalar
ingredient_scalar_function(::Type{<:Crafted}) = craft_ingredient_scalar

"""
    delta(r::Recipie, modifiers = DEFAULT_MODIFIERS)

Returns an [`Inventory`](@ref) that would be the effect of applying
the [`Recipie`](@ref).  `modifiers` is a vector of the player's
current [`Modifier`](@ref)s.
"""
function delta(r::Recipie, modifiers = DEFAULT_MODIFIERS)
    multiplier = reduce(*, map(ingredient_scalar_function(r.make), modifiers);
                        init = 1.0)
    if r.make <: Thing
        r.make(1) + multiplier * r.ingredients
    else
        multiplier * r.ingredients
    end
end


ALL_RECIPIES = Recipie[]

lookup_recipie(want::AbstractString) = best_thing_match(want, ALL_RECIPIES)

lookup_recipie(want::Type) = only(filter(r -> r.make == want,
                                         ALL_RECIPIES))

macro rx_str(name)
    return :(lookup_recipie($name))
end

