using InteractiveUtils
using StringDistances

export Thing, Ore, Alloy, Crafted
export ordinal, all_things, best_thing_match, @t_str

include_dependency(joinpath(@__DIR__, "Ores"))
include_dependency(joinpath(@__DIR__, "Alloys"))
include_dependency(joinpath(@__DIR__, "Crafted"))


"""
`Thing` is the abstract supertype of [`Ore`](@ref), [`Alloy`](@ref) and
[`Crafted`](@ref).
"""
abstract type Thing end

"""
`Ore` is the abstract supertype for anything that is mined.
"""
abstract type Ore <: Thing end

"""
`Alloy` is the abstract supertype of anything that is smelted from
[`Ore`](@ref) or other [`Alloy`](@ref)s.
"""
abstract type Alloy <: Thing end

"""
`Crafted` is the abstract suppertype of anything that is crafted from
other [`Thing`](@ref)s.
"""
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


"""
    all_things()

returns a list of all concrete subtypes of [`Thing`](@ref) in canonical order.
"""
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


namestring(s::AbstractString) = s
namestring(n::Type) = namestring(nameof(n))
namestring(s::Symbol) = string(s)


function best_thing_match(name::AbstractString, collection=all_things())
    distances = [ evaluate(Levenshtein(), name, namestring(candidate))
                  for candidate in collection ]
    _, index = findmin(distances)
    collection[index]
end


macro t_str(name)
    return :(best_thing_match($name)(1))
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
                         count::Real
                         $name(count) = new(round(count, digits=3))
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
                         count::Real
                         $name(count) = new(round(count, digits=3))
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
                         count::Real
                         $name(count) = new(round(count, digits=3))
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

