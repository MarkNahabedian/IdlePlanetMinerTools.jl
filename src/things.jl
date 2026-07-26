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

Every subtype of `Thing` has a `count` field.
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


"""
    base_selling_price(::Type{<:Thing})
    base_selling_price(::Thing)

Returns the base selling price for the thing.

For instances it multiplies the unit price by the count.
"""
base_selling_price(t::Type{<:Thing}) =
    error("base_selling_price for $t not defined.")

base_selling_price(t::Thing) = t.count * base_selling_price(typeof(t))


PARSE_MATERIALS_MULTIPLIER_SUFFIXES = Dict([
    "" => 1,
    " " => 1,
    "k" => 1000,
    "K" => 1000,
    "M" => 1000000,
    "B" => 10 ^ (3 * 3),
    "T" => 10 ^ (3 * 4),
    "q" => 10 ^ (3 * 5),
    "Q" => 10 ^ (3 * 6),
    "s" => 10.0 ^ (3 * 7)
])

function parse_selling_price(s::AbstractString)
    re = r"(?<val>[0-9.]+)(?<mult>.?)"
    m = match(re, s)
    if m isa RegexMatch
        return parse(Float32, m["val"]) *
            PARSE_MATERIALS_MULTIPLIER_SUFFIXES[m["mult"]]
    else
        error("Unrecognized price: $s")
    end
end

function define_base_selling_price_method(type, s::AbstractString)
    price = parse_selling_price(s)
    eval(:(base_selling_price(::Type{$type}) = $price))
end


