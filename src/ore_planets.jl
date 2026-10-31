
function make_ore_planets()
    result = OrderedDict{Type{<:Ore}, Vector{Planet}}(
        (o => Planet[] for o in subtypes(Ore)))
    for planet in ALL_PLANETS
        for oy in planet.ores
            key = oy.ore
            push!(result[key], planet)
        end
    end
    for (k, v) in result
        result[k] = sort(result[k]; by = p -> p.number)
    end
    result
end

