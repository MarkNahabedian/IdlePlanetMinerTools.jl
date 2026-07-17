using InteractiveUtils

export Thing, Ore, Alloy, Crafted
export ordinal, @t_str

abstract type Thing end
abstract type Ore <: Thing end
abstract type Alloy <: Thing end
abstract type Crafted <: Thing end


"""
    ordinal(thing)

Returns the ordinal number for `thing`, where `thing` is either a
subtype of `Thing` or an instance of a subtype of `Thing`.
"""
ordinal(t::Thing) = ordinal(typeof(t))


map(eval,
    let
        exprs = []
        ord = 0
        for ore in eachline(joinpath(@__DIR__, "Ores"))
            ord += 1
            m = match(r"^[A-Za-z]+", ore)
            if m == nothing
                continue
            end
            name = Symbol(m.match)
            push!(exprs,
                  (:(mutable struct $name <: Ore
                         count::Int
                     end)))
            push!(exprs,
                  (:(export $name)))
            push!(exprs,
                  :(ordinal(::Type{$name}) = $ord))
        end
        exprs
    end)

map(eval,
    let
        exprs = []
        ord = maximum(ordinal, subtypes(Ore))
        for alloy in eachline(joinpath(@__DIR__, "Alloys"))
            ord += 1
            m = match(r"^(?<name>[A-Za-z]+ Alloy|Bar)", alloy)
            if m == nothing
                continue
            end
            name = Symbol(replace(m["name"], " " => ""))
            push!(exprs,
                  (:(mutable struct $name <: Alloy
                         count::Int
                     end)))
            push!(exprs,
                  (:(export $name)))
            push!(exprs,
                  :(ordinal(::Type{$name}) = $ord))
        end
        exprs
    end)

map(eval,
    let
        exprs = []
        ord = maximum(ordinal, subtypes(Alloy))
        for alloy in eachline(joinpath(@__DIR__, "Crafted"))
            ord += 1
            m = match(r"[A-Za-z ]+", alloy)
            if m == nothing
                continue
            end
            name = Symbol(replace(m.match, " " => ""))
            push!(exprs,
                  (:(mutable struct $name <: Crafted
                         count::Int
                     end)))
            push!(exprs,
                  (:(export $name)))
            push!(exprs,
                  :(ordinal(::Type{$name}) = $ord))
        end
        exprs
    end)

#=
@assert 1 == minimum(ordinal, subtypes(Ore))
@assert maximum(ordinal, subtypes(Ore)) + 1 == minimum(ordinal, subtypes(Alloy))
@assert maximum(ordinal, subtypes(Alloy)) + 1 == minimum(ordinal, subtypes(Crafted))
@assert 1:87 == sort(map(ordinal, union([ subtypes(x) for x in subtypes(Thing) ]...)))
# jump from 27 to 41
=#

macro t_str(name)
    return :($(Symbol(name))(1))
end

