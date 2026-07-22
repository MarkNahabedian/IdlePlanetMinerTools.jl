# Extract alloy definitions.

using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames

include_dependency(joinpath(@__DIR__, "alloys.csv"))

export fetch_alloys, make_alloy_recipies

PROJECTS_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Alloys"


function fetch_alloys()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, PROJECTS_SOURCE)
        table = only(eachmatch(Cascadia.Selector("table.article-table"), page.root))
        rows = eachmatch(Cascadia.Selector("table.article-table tr"), table)
        # First ro is headings.
        column_headings = map(text, eachmatch(Cascadia.Selector("th"), rows[1]))[2:end]
        df = DataFrame([ h => String[] for h in column_headings ])
        for row in rows[2:end]
            tds = eachmatch(Cascadia.Selector("td"), row)
            # tds[1] is an image
            # tds[2] is the name, but inside a link
            data = map(text, tds[2:end])
            push!(df, data)
        end
        CSV.write(joinpath(@__DIR__, "alloys.csv"), df)
        df
    end
end


function make_alloy_recipies()
    recipies = Recipie[]
    df = CSV.read(joinpath(@__DIR__, "alloys.csv"), DataFrame)
    # Alloys,Cost To Unlock,Material Cost,Time to Smelt,Sell Price,Crafting uses
    for row in eachrow(df)
        name1 = row["Alloys"]
        type = best_thing_match(name1)
        materials = row["Material Cost"]
        duration = row["Time to Smelt"]
        if isa(duration, AbstractString)
            m = match(r"([0-9,]+)", duration)
            if m == nothing
                @warn("Unrecognized duration $duration")
                continue
            end
            duration = m.match
            duration = parse(Int, replace(duration, "," => "")) 
        end
        materials = - parse_materials_string(name1, materials)
        push!(recipies, Recipie(type, materials, duration))
    end
    recipies
end

