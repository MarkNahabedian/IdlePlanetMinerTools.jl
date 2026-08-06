
export Planet, fetch_planets

include_dependency(joinpath(@__DIR__, "planets.csv"))

PLANETS_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Planets"

struct OreYield
    ore::Ore
    yield::Float32
end

struct Planet
    number::Int
    name::String
    telescope::Project
    ores::Vector{OreYield}
end


function fetch_planets()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, PLANETS_SOURCE)
        table = eachmatch(Cascadia.Selector("table.article-table"), page.root)[1]
        rows = eachmatch(Cascadia.Selector("table.article-table tr"), table)
        column_headings = map(text, eachmatch(Cascadia.Selector("th"), rows[1]))
        println(column_headings)
        resources_column = findfirst(==("Resources"), column_headings)
        yield_column = findfirst(==("Yield (%)"), column_headings)
        df = DataFrame([ h => String[] for h in column_headings ])
        previous = nothing
        for row in rows[2:end]
            tds = eachmatch(Cascadia.Selector("td"), row)
            if length(tds) == length(column_headings)
                data = map(text, tds)
                previous = data
                println(data)
                push!(df, data)
            elseif length(tds) == 2
                data = map(text, tds)
                previous[resources_column] = data[1]
                previous[yield_column] = data[2]
                push!(df, previous)
            end
        end
        CSV.write(joinpath(@__DIR__, "planets.csv"), df)
        df
    end
end
