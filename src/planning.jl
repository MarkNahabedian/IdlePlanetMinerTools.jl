using Format

# A simple planner.

export PlanJunction, AnyOf, AllOf, precursor, development_level,
    walk_precursors, show_tiered_production_plan, identify_revenue_items


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
    precursor(t::Type{<:Thing})

The precursor of any subtype of `Thing` that is not a subtype of
`Ore` is `AllOf` the ingredients of its `Recipie`.
"""
function precursor(t::Type{<:Thing})
    r = lookup_recipie(t)
    AllOf(map(typeof, r.ingredients))
end


"""
    function precursor(o::Type{<:Ore})

The precursor of an Ore is any of the Planets that provide that Ore.

We restrict the result to those planets with the lowest Telescope
number.
"""
function precursor(o::Type{<:Ore})
    # Return a Project's ranking as a Telescope.  Non-Telescopes are
    # assigned the typemax so actual Telescopes will be ordered lower.
    function telescope_number(t::Type{<:Project})
        m = match(r"Telescope(?<num>[0-9]+)", string(nameof(t)))
        if m == nothing
            # Any actual telescope will be less than this:
            return typemax(Int)
        else
            return parse(Int, m["num"])
        end
    end
    best_telescope = typemax(Int)
    best = Planet[]
    for p in ALL_PLANETS
        if provides_ore(p, o)
            if p.telescope == nothing
                best_telescope = 0
                push!(best, p)
            else
                tnum = telescope_number(p.telescope)
                if tnum < best_telescope
                    empty!(best)
                    best_telescope = tnum
                    push!(best, p)
                elseif tnum == best_telescope
                    push!(best, p)
                end
            end
        end
    end
    AnyOf(best)
end

precursor(t::Thing) = precursor(typeof(t))

precursor(a::Type{<:Alloy}) =
    AllOf([Smelter,
           map(precursor,
               map(typeof,
                   lookup_recipie(a).ingredients.items))...])

precursor(c::Type{Crafted}) =
    AllOf([Crafter,
           map(precursor,
               map(typeof,
                   lookup_recipie(c).ingredients.items))...])

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

#=

It would be nice to have a graph that shows the dependencies that
gives us a "layered" view of the dependencies.

I think we need to start with a map from entities to what they are
precursors for.

=#

export make_precursor_to_postcursor_map

function make_precursor_to_postcursor_map()
    result = Dict{Any, Vector}()
    result[nothing] = []
    function note(pre, post)
        if !haskey(result, pre)
            result[pre] = []
        end
        if post in result[pre]
            return false
        end
        push!(result[pre], post)
        return true
    end
    function walk(x)
        if x isa Nothing
            return
        end
        if x isa PlanJunction
            for pre1 in x.precursors
                if note(pre1, x)
                    walk(pre1)
                end
            end
            return
        end
        pre = precursor(x)
        if pre isa Nothing
            note(nothing, x)
        else
            if note(pre, x)
                walk(pre)
            end
        end
    end
    for project in all_projects()
        walk(project)
    end
    result
end


"""
    development_level(x)

Return the "development level" of `x`.

It's clear that there are steps in the precursor graph based on
distance from the null precursor to `x` and what steps are on that
path.  For example, A given type of Ore has a development level that
is 1 greater than the earliest planet that produces it.
"""
function development_level end

CACHED_DEVELOPMENT_LEVEL = Dict{Any, Int}()

function development_level(x)
    if !haskey(CACHED_DEVELOPMENT_LEVEL, x)
        CACHED_DEVELOPMENT_LEVEL[x] = development_level1(x)
    end
    CACHED_DEVELOPMENT_LEVEL[x]
end

development_level1(::Nothing) = 0

development_level1(x::Any) = development_level(precursor(x)) + 1

development_level1(a::AllOf) = maximum(development_level, a.precursors)

development_level1(a::AnyOf) = minimum(development_level, a.precursors)


"""
    walk_precursors(f, x)

Applies the function `f` to x and all of its `precursor`s.
"""
function walk_precursors end


walk_precursors(f, x::Nothing) = nothing

function walk_precursors(f, x::Any)
    f(x)
    walk_precursors(f, precursor(x))
end
    
function walk_precursors(f, a::PlanJunction)
    for x in a
        walk_precursors(f, x)
    end
end


"""
    intralevel_ordering(a, b)

Implements a sort ordering for the elements withing a given level in
`show_tiered_production_plan`.

  * smaller numbered planets before larger numbered ones.
  * arbitrarily sort planents before projects
  * arbitrarily sort other things last any others?

"""
function intralevel_ordering end

intralevel_ordering(a::Planet, b::Planet) = isless(a.number, b.number)
intralevel_ordering(a::Type{<:Project}, b::Type{<:Project}) =
    isless(base_selling_price(lookup_recipie(a).ingredients),
           base_selling_price(lookup_recipie(b).ingredients))
intralevel_ordering(a::Type{<:Thing}, b::Type{<:Thing}) =
    isless(base_selling_price(a), base_selling_price(b))

intralevel_ordering(a::Planet, b::Type{<:Project}) = true
intralevel_ordering(a::Type{<:Project}, b::Planet) = false
intralevel_ordering(a::Planet, b::Type{<:Thing}) = true
intralevel_ordering(a::Type{<:Thing}, b::Planet) = false
intralevel_ordering(a::Type{<:Project}, b::Type{<:Thing}) = true
intralevel_ordering(a::Type{<:Thing}, b::Type{<:Project}) = false


tiered_prodiction_plan_string(::GameState, x::Any; keyargs...) =
    "??? $(string(x)) $(typeof(string(x)))"

function tiered_prodiction_plan_string(game::GameState, x::Type{<:Alloy}; keyargs...)
    ingredients = join(collect(lookup_recipie(x).ingredients), ", ")
    "$(nameof(x)) \$$(cost_to_unlock(x)) [$ingredients]"
end

function tiered_prodiction_plan_string(game::GameState, x::Type{<:Crafted}; keyargs...)
    ingredients = join(collect(lookup_recipie(x).ingredients), ", ")
    "$(nameof(x)) \$$(cost_to_unlock(x)) [$ingredients]"
end

function tiered_prodiction_plan_string(game::GameState, x::Planet; keyargs...)
    # Skip if we already have it:
    if in(x, game.planets)
        return nothing
    end
    produces = join(map(y -> y.ore, x.ores), ", ")
    join([
        "$(x.number).$(x.name)",
        "\$$(x.base_price)",
        "($(planet_direction(x))$(DIRECTION_ARROWS[PLANET_DIRECTIONS[x.number]]))",
        "[ $produces ]"
    ],
         " ")
end

struct RevenueThing
    recipie::Recipie
    level::Int
    revenue::Float64
    appreciation_per_time::Float64
end

function tiered_prodiction_plan_string(game::GameState, rt::RevenueThing; keyargs...)
    r = format(rt.revenue, commas=true)
    "\$ $(nameof(rt.recipie.make)) \$$r"
end

intralevel_ordering(a::RevenueThing, b::Any) = false
intralevel_ordering(a::Any, b::RevenueThing) = true
intralevel_ordering(a::RevenueThing, b::RevenueThing) =
    error("More than one RevenueThing: $a, $b.")


function identify_revenue_items()
    df = CSV.read(THING_EFFICIENCIES_CSV, DataFrame)
    levels = Dict{Int, RevenueThing}()
    for row in eachrow(df)
        # df is already sorted, so the first thing for a given level
        # should be the best.
        if haskey(levels, row.development_level)
            continue
        end
        recipie = lookup_recipie(row.name)
        levels[row.development_level] =
            RevenueThing(recipie,
                         row.development_level,
                         row.sell_price,
                         row.appreciation_per_time)
    end
    best_apt = 0    # appreciation_per_time
    # We should exclude any items for which there is an item at an
    # earlier level with better appreciation_per_time.
    for level in sort(collect(keys(levels)))
        if levels[level].appreciation_per_time > best_apt
            best_apt = levels[level].appreciation_per_time
        else
            delete!(levels, level)
        end
    end
    sort(collect(values(levels)); by = x -> x.level)
end

function tiered_prodiction_plan_string(game::GameState, x::Type{<:Project};
                                       desired_projects=[], keyargs...)
    # Skip if we already have it:
    if has_modifier(game, x)
        return nothing
    end
    coord = PROJECT_CHART_COORDINATES[x]
    name = "$x"
    if x in desired_projects
        name = "*$(name)*"
    end
    d = delta(lookup_recipie(x), game)
    items = join(map(round, d.items), ", ")
    "$name $coord  $items"
end

function show_tiered_production_plan(game::GameState,
                                     desired_projects::Vector{Type{<:Project}})
    levels = Dict{Int, Set{Any}}()
    function note(x)
        dl = development_level(x)
        if !haskey(levels, dl)
            levels[dl] = Set()
        end
        push!(levels[dl], x)
    end
    for p in desired_projects
        walk_precursors(note, p)
    end
    for rt in identify_revenue_items()
        l = rt.level
        if !haskey(levels, l)
            levels[l] = Set()
        end
        push!(levels[l], rt)
    end
    for level in sort(collect(keys(levels)))
        level_output = IOBuffer()
        for x in sort(collect(levels[level]); lt = intralevel_ordering)
            tpps = tiered_prodiction_plan_string(game, x; desired_projects)
            if tpps isa String
                println(level_output, tpps)
            end
            if level_output.size > 0
                print("LEVEL $level:  \t")
                write(stdout, String(take!(level_output)))
            end
        end
    end
end


#=

show_tiered_production_plan(GameState(), Type{<:Project}[
    process_ingredientspeed_reduction_projects()...,
    process_speed_enhancement_projects()...,
    Smelter,
    Crafter,
    Beacon,
    Rover,
    AdvancedMining,
    AdvancedThrusters,
    AdvancedCargoHandling,
    SuperiorMining,
    SuperiorThrusters,
    SuperiorCargoHandling,
    PreferredVendor,
    AsteroidAutoMiner,
    SuperiorAsteroidHarvester,
    FurnaceOverdrive,
    DebrisScanner
])

=#

