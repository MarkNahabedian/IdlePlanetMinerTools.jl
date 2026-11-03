# Determine costs and efficiencies for all Things.

export ThingConsolidatedCosts, thing_cost, all_things_colsolidated_costs_sorted

"""
    ThingConsolidatedCosts

returned by [`thing_cost`](@ref), encapsulates various production
"cost" related values for a `Thing`.
"""
struct ThingConsolidatedCosts
    "The Thing itself."
    thing::Type{<:Thing}
    "The result of calling [`development_level`](@ref)."
    development_level::Int
    "The base selling price for the `Thing`."
    sell_price::Float64
    "The transitive total base selling price of all ores to produce the `Thing`."
    total_ore_cost::Float64
    "The total time needed for all smelting operations required to produce the `Thing`."
    smelting_time::Float64
    "The total time needed for all crafting operations required to produce the `Thing`."
    crafting_time::Float64
    "True if a crafting time was not available for some crafting operation."
    time_missing::Bool
end

"""
    Base.getproperty(x::ThingConsolidatedCosts, ::Val{:name})

The name of the `Thing` as a `String`.
"""
Base.getproperty(x::ThingConsolidatedCosts, ::Val{:name}) =
    string(nameof(x.thing))

"""
    Base.getproperty(x::ThingConsolidatedCosts, ::Val{:appreciation})

The difference in value between `sell_price` and `total_ore_cost`.
"""
Base.getproperty(x::ThingConsolidatedCosts, ::Val{:appreciation}) =
    x.sell_price / x.total_ore_cost


"""
    Base.getproperty(x::ThingConsolidatedCosts, ::Val{:appreciation_per_time}) =

appreciation` divided by the sum of `smelting_time` and `crafting_time`.
"""
Base.getproperty(x::ThingConsolidatedCosts, ::Val{:appreciation_per_time}) =
    x.appreciation / (x.smelting_time + x.crafting_time)

@property_trampolines ThingConsolidatedCosts


"""
    thing_cost(thing::Type{<:Thing}, game::GameState)

Returns a [`ThingConsolidatedCosts`](@ref) which collects various
production related "costs" for the `Thing`.
"""
function thing_cost(thing::Type{<:Thing}, game::GameState)
    cp = crafting_plan(Inventory(thing(-1)), game)[1]
    name = string(nameof(thing))
    level = development_level(thing)
    sell_price = base_selling_price(thing)
    # Smelt time and craft time can overlap.
    time_missing = false
    total_time = Dict{Process, Int}([
        p() => 0.0
        for p in subtypes(Process) ])
    # We only consider Ore cost because everything else is
    # processed from Ore plus time:
    total_ore_cost = 0
    for ca in cp
        proc = to_make(ca.recipie)
        if ca.recipie.duration_seconds isa Missing
            time_missing = true
        else
            total_time[proc] += ca.count * ca.recipie.duration_seconds
        end
        for t in ca.recipie.ingredients
            if t isa Ore
                total_ore_cost += - base_selling_price(t) * ca.count
            end
        end
    end
    return ThingConsolidatedCosts(thing,
                                  level, sell_price, total_ore_cost,
                                  total_time[Smelt()],
                                  total_time[Craft()],
                                  time_missing)
end

all_things_colsolidated_costs_sorted(; game = GameState()) =
    sort(map(t -> thing_cost(t, game), all_things());
         by = x -> x.appreciation_per_time,
         rev=true)

