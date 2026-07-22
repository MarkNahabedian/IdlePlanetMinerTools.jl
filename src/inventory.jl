
export Inventory

"""
An `Inventory` represents a collection of [`Thing`](@ref)s.
"""
struct Inventory
    items::Vector{Thing}

    Inventory(thing::Thing) = new(Thing[thing])

    Inventory(things::Thing...) = Inventory(Thing[things...])

    function Inventory(things::Vector{<:Thing})
        things = sort(things; by = ordinal)
        merged = Thing[]
        for thing in things
            if lastindex(merged) >= 1 && typeof(thing) === typeof(last(merged))
                merged[lastindex(merged)] = typeof(thing)(thing.count +
                    merged[lastindex(merged)].count)
            else
                push!(merged, thing)
            end
        end
        new(merged)
    end
end

Base.convert(::Type{Inventory}, thing::Thing) = Inventory(thing)

