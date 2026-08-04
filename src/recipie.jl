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

ALL_RECIPIES = Recipie[]


namestring(r::Recipie) = namestring(r.make)

base_selling_price(r::Recipie) = base_selling_price(r.ingredients)

Base.isless(a::Recipie, b::Recipie) =
    base_selling_price(a) < base_selling_price(b)


"""
    delta(r::Recipie, modifiers = DEFAULT_MODIFIERS)

Returns an [`Inventory`](@ref) that would be the effect of applying
the [`Recipie`](@ref).  `modifiers` is a vector of the player's
current [`Modifier`](@ref)s.

It appears that the game rounds the result to the nearest integer.
I've not yet decided if that should happen here.
"""
function delta(r::Recipie, modifiers = DEFAULT_MODIFIERS)
    multiplier = reduce(*,
                        map(m -> process_ingredient_scalar(to_make(r.make), m),
                            modifiers);
                        init = 1.0)
    if r.make <: Thing
        r.make(1) + multiplier * r.ingredients
    else
        multiplier * r.ingredients
    end
end


lookup_recipie(want::AbstractString) = best_thing_match(want, ALL_RECIPIES)

lookup_recipie(want::Type) = only(filter(r -> r.make == want,
                                         ALL_RECIPIES))

macro rx_str(name)
    return :(lookup_recipie($name))
end

