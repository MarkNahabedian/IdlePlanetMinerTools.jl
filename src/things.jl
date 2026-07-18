using InteractiveUtils
using StringDistances

export Thing, Ore, Alloy, Crafted
export ordinal, all_things, best_thing_match, @t_str

include_dependency(joinpath(@__DIR__, "Ores"))
include_dependency(joinpath(@__DIR__, "Alloys"))
include_dependency(joinpath(@__DIR__, "Crafted"))

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


function canonicalize_name(name)
    s = split(name, " ")
    s = map(uppercasefirst, s)
    join(s)
end


function all_things()
    things = Type{<:Thing}[]
    function walk(t)
        if isconcretetype(t)
            push!(things, t)
        else
            walk.(subtypes(t))
        end
    end
    walk(Thing)
    sort(things; by = ordinal)
end

function best_thing_match(name::AbstractString)
    candidates = map(string, map(nameof, all_things()))
    distances = [ evaluate(Levenshtein(), name, candidate)
                  for candidate in candidates ]
    _, index = findmin(distances)
    candidates[index]
end


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
            name = Symbol(canonicalize_name(m.match))
            push!(exprs,
                  (:(struct $name <: Ore
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
            m = match(r"^(?<name>[A-Za-z]+ (Bar|Alloy))", alloy)
            if m == nothing
                continue
            end
            name = Symbol(canonicalize_name(m["name"]))
            push!(exprs,
                  (:(struct $name <: Alloy
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
        for crafted in eachline(joinpath(@__DIR__, "Crafted"))
            ord += 1
            m = match(r"[A-Za-z ]+", crafted)
            if m == nothing
                continue
            end
            name = Symbol(canonicalize_name(m.match))
            push!(exprs,
                  (:(struct $name <: Crafted
                         count::Int
                     end)))
            push!(exprs,
                  (:(export $name)))
            push!(exprs,
                  :(ordinal(::Type{$name}) = $ord))
        end
        exprs
    end)

@assert 1 == minimum(ordinal, subtypes(Ore))
@assert maximum(ordinal, subtypes(Ore)) + 1 == minimum(ordinal, subtypes(Alloy))
@assert maximum(ordinal, subtypes(Alloy)) + 1 == minimum(ordinal, subtypes(Crafted))
@assert 1:99 == sort(map(ordinal, union([ subtypes(x) for x in subtypes(Thing) ]...)))


macro t_str(name)
    return :($(Symbol(name))(1))
end

