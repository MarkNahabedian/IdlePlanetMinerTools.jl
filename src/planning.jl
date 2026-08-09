# A simple planner.

export PlanJunction, AnyOf, AllOf, precursor


abstract type PlanJunction end

import Base: ==

function ==(a::T, b::T) where T <: PlanJunction
    return a.precursors == b.precursors
end

Base.isequal(a::T, b::T) where T <: PlanJunction =
    a.precursors == b.precursors

Base.hash(a::PlanJunction, h::UInt) = hash(a.precursors, h)

Base.isempty(x::PlanJunction) = isempty(x.precursors)

Base.length(x::PlanJunction) = length(x.precursors)

Base.IteratorSize(::Type{PlanJunction}) = Base.HasLength()

Base.IteratorEltype(::Type{PlanJunction}) = Base.EltypeUnknown()

Base.iterate(x::PlanJunction) = iterate(x.precursors)
Base.iterate(x::PlanJunction, state) = iterate(x.precursors, state)


struct AnyOf <: PlanJunction
    precursors::Set

    AnyOf(v::Vector) = new(Set(v))
end

struct AllOf <: PlanJunction
    precursors::Set

    AllOf(v::Vector) = new(Set(v))
end


# There are tradeoffs concerning how complicated/detailed we want the
# results of `precursor` to be.


"""
    precursor(x)

Returns the precursor (for planning purposes) of `x`.
"""
function precursors end


"""
    precursor(::Planet)

The precursor of a Planet is a Telescope.
"""
precursor(p::Planet) = p.telescope


"""
    function precursor(o::Type{<:Ore})

The precursor of an Ore is any of the Planets that provide that Ore.

We restrict the result to those planets with the lowest Telescope
number.
"""
function precursor(o::Type{<:Ore})
    function telescope_number(t::Type{<:Project})
        m = match(r"Telescope(?<num>[0-9]+)", string(nameof(t)))
        if m == nothing
            # Any actual telescope will be less than this:
            typemax(Int)
        else
            parse(Int, m["num"])
        end
    end
    best_telescope = nothing
    best = Planet[]
    for p in ALL_PLANETS
        if provides_ore(p, o)
            if p.telescope == nothing
                best_telescope = 0
                push!(best, p)
            else
                if (best_telescope == nothing ||
                    telescope_number(p.telescope) < best_telescope)
                    empty!(best)
                    best_telescope = telescope_number(p.telescope)
                    push!(best, p)
                elseif telescope_number(p.telescope) == best_telescope
                    push!(best, p)
                end
            end
        end
    end
    AnyOf(best)
end

precursor(o::Ore) = precursor(typeof(o))

precursor(t::Thing) = lookup_recipie(typeof(t))

precursor(r::Recipie) = AllOf(map(typeof, r.ingredients.items))

precursor(p::Project) = precursor(typeof(p))

function precursor(p::Type{<:Project})
    r = lookup_recipie(p)
    prereq = prerequisites(p)
    if length(prereq) > 1
        prereq = [AnyOf(prereq)]
    end
    AllOf([prereq..., map(typeof, r.ingredients)...])
end

