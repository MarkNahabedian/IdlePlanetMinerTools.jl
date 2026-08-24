# Determine costs and efficiencies for all Things.

using DataFrames

export compute_thing_costs

function thing_cost(thing::Type{<:Thing}, game::GameState)
    cp = crafting_plan(Inventory(thing(-1)), game)[1]
    name = string(nameof(thing))
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
    return (
        name = name,
        sell_price = sell_price,
        total_ore_cost = total_ore_cost,
        smelting_time = total_time[Smelt()],
        crafting_time = total_time[Craft()],
        time_missing = time_missing
    )
end

function compute_thing_costs()
    game = GameState()
    df = DataFrame(
        :name => String[],
        :sell_price => Float64[],
        :total_ore_cost => Float64[],
        :smelting_time => Float64[],
        :crafting_time => Float64[],
        :time_missing => Bool[]
    )
    for thing in all_things()
        if thing <: Ore
            continue
        end
        push!(df, thing_cost(thing, game))
    end
    CSV.write(joinpath(@__DIR__, "thing_efficiencies.csv"), df)
    df
end

