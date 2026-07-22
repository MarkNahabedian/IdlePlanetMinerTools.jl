export Recipie, ALL_RECIPIES, delta, lookup_recipie, @rx_str

struct Recipie
    make    # ::Type{<:Union{Thing, Project}}
    ingredients::Inventory
    duration_seconds::Union{Missing, Int}

    Recipie(name, ingredients::Inventory, duration_seconds) =
        new(name, ingredients, duration_seconds)
end

namestring(r::Recipie) = namestring(r.make)

function delta(r::Recipie, modifiers = DEFAULT_MODIFIERS)
    multiplier = reduce(*, map(smelt_ingredient_scalar, modifiers);
                        init = 1.0)
    r.make(1) + multiplier * r.ingredients
end


ALL_RECIPIES = Recipie[]

lookup_recipie(want::AbstractString) = best_thing_match(want, ALL_RECIPIES)   

macro rx_str(name)
    return :(lookup_recipie($name))
end

