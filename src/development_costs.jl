# Determine costs and efficiencies for all Things.

using DataFrames, CSV

export compute_thing_costs, THING_EFFICIENCIES_CSV


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
    return (
        name = name,
        development_level = level,
        sell_price = sell_price,
        total_ore_cost = total_ore_cost,
        smelting_time = total_time[Smelt()],
        crafting_time = total_time[Craft()],
        time_missing = time_missing
    )
end

THING_EFFICIENCIES_CSV = joinpath(@__DIR__, "thing_efficiencies.csv")


"""
    compute_thing_costs()

Computes a DataFrame of the production costs and process durations for each `Thing`.
Returns the DataFrame and also saves it to `src/thing_efficiencies.csv`.
"""
function compute_thing_costs()
    game = GameState()
    df = DataFrame(
        :name => String[],
        :development_level => Int[],
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
    transform!(df,
               [ :sell_price, :total_ore_cost ] =>
                   ByRow((sell_for, cost) -> sell_for / cost) =>
                   :appreciation)
    transform!(df,
               [ :smelting_time, :crafting_time, :appreciation] =>
                   ByRow((st, ct, a) -> a / (st + ct)) =>
                   :appreciation_per_time)
    sort!(df, :appreciation_per_time, rev=true)
    CSV.write(THING_EFFICIENCIES_CSV, df)
    df
end


