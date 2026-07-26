# Extract ore definitions.

using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames

include_dependency(joinpath(@__DIR__, "ores.csv"))

export fetch_ores, make_ore_definitions

ORE_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Ores"

function fetch_ores()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, ORE_SOURCE)
        table = only(eachmatch(Cascadia.Selector("table.article-table"), page.root))
        rows = eachmatch(Cascadia.Selector("table.article-table tr"), table)
        # First row is headings.
        column_headings = map(text, eachmatch(Cascadia.Selector("th"), rows[1]))[2:end]
        df = DataFrame([ h => String[] for h in column_headings ])
        for row in rows[2:end]
            tds = eachmatch(Cascadia.Selector("td"), row)
            # tds[1] is an image
            # tds[2] is the name, but inside a link
            data = map(text, tds[2:end])
            push!(df, data)
        end
        CSV.write(joinpath(@__DIR__, "ores.csv"), df)
        df
    end
end

function make_ore_definitions()
    df = CSV.read(joinpath(@__DIR__, "ores.csv"), DataFrame)
    ord = 0
    # Ores,Sell Price,Straight smelt uses.,Requires multiple smelts
    for row in eachrow(df)
        ord += 1
        name1 = row["Ores"]
        type = Symbol(canonicalize_name(name1))
        eval(:(begin
                   export $type
                   struct $type <: Ore
                       count::Real
                       $type(count) = new(round(count, digits=3))
                   end
                   ordinal(::Type{$type}) = $ord
               end))
        define_base_selling_price_method(type, row["Sell Price"])
    end
end

make_ore_definitions()

