export Recipie, ALL_RECIPIES, delta, lookup_recipie, @rx_str

struct Recipie
    make    # ::Type{<:Union{Thing, Project}}
    ingredients::Inventory
    duration_seconds::Union{Missing, Int}

    Recipie(name, ingredients::Inventory, duration_seconds) =
        new(name, ingredients, duration_seconds)
end

namestring(r::Recipie) = namestring(r.make)

delta(r::Recipie) = r.make(1) + r.ingredients


ALL_RECIPIES = Recipie[]

lookup_recipie(want::AbstractString) = best_thing_match(want, ALL_RECIPIES)   

macro rx_str(name)
    return :(lookup_recipie($name))
end

