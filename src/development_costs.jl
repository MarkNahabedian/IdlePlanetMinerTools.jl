# Determine costs and efficiencies for all Things.

export ThingConsolidatedCosts, thing_cost, all_things_colsolidated_costs_sorted

struct ThingConsolidatedCosts
    thing::Type{<:Thing}
    name::AbstractString
    development_level::Int
    sell_price::Float64
    total_ore_cost::Float64
    smelting_time::Float64
    crafting_time::Float64
    time_missing::Bool
end

appreciation(x::ThingConsolidatedCosts) = x.sell_price / x.total_ore_cost

appreciation_per_time(x::ThingConsolidatedCosts) =
    appreciation(x) / (x.smelting_time + x.crafting_time)


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
                                  name, level, sell_price, total_ore_cost,
                                  total_time[Smelt()],
                                  total_time[Craft()],
                                  time_missing)
end

all_things_colsolidated_costs_sorted(; game = GameState()) =
    sort(map(t -> thing_cost(t, game), all_things());
         by = x -> appreciation_per_time(x),
         rev=true)

