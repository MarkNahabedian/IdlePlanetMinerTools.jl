using InteractiveUtils
using StringDistances

export Thing, Ore, Alloy, Crafted
export ordinal, all_things, best_thing_match, @t_str, canonicalize_name,
    parse_selling_price, base_selling_price, cost_to_unlock


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


Base.round(t::Thing) = typeof(t)(round(Int, t.count))

function Base.isapprox(x::T, y::T; atol, rtol, nans, norm) where T <: Thing
    isapprox(x.count, y.count; atol, rtol, nans, norm)
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


"""
    cost_to_unlock(::Type{<:Thing})

Returns the cost to unlock the type's recipie.
"""
cost_to_unlock(t::Type{<:Thing}) =
    error("cost_to_unlock for $t not defined.")



PARSE_MATERIALS_MULTIPLIER_SUFFIXES = Dict{String, Signed}([
    "" => 0,
    " " => 0,
    "k" => 3,
    "K" => 3,
    "M" => 6,
    "B" => 9,
    "T" => 12,
    "q" => 15,
    "Q" => 18,
    "s" => 21,
    "S" => 24,
    "O" => 27,
    "N" => 30
])

function parse_selling_price(s::AbstractString)
    re = r"(?<whole>[0-9]+)([.](?<frac>[0-9]+)?)? ?(?<mult>[a-zA-Z]?)"
    m = match(re, s)
    if m isa RegexMatch
        whole = parse(Int, m["whole"])
        exp = PARSE_MATERIALS_MULTIPLIER_SUFFIXES[m["mult"]]
        whole = whole * BigInt(10) ^ exp
        frac = 0
        mfrac = m["frac"]
        if mfrac isa AbstractString && length(mfrac) > 0
            frac = parse(Int, mfrac)
            frac = frac * BigInt(10) ^ (exp - length(mfrac))
        end
        return whole + frac
    elseif s == "Free"
        return 0
    else
        error("Unrecognized price: $s")
    end
end

function define_base_selling_price_method(type, s::AbstractString)
    price = parse_selling_price(s)
    eval(:(base_selling_price(::Type{$type}) = $price))
end

function define_cost_to_unlock_method(type, s::AbstractString)
    price = parse_selling_price(s)
    name = Symbol(canonicalize_name(type))
    eval(:(cost_to_unlock(::Type{$name}) = $price))
end

