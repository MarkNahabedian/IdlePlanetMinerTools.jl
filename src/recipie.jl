export Recipie, ALL_RECIPIES

struct Recipie
    make::Type{<:Thing}
    ingredients::Vector{Thing}
    duration_seconds::Int

    Recipie(name, ingredients, duration_seconds) =
        new(name, sort(ingredients; by = ordinal), duration_seconds)
end

ALL_RECIPIES = Recipie[]

