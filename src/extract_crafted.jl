# Fetch item information from the IdlePlanetMiner WIKI

export fetch_crafted, make_crafted_recipies, parse_material

RECIPIE_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Items"


# The original list I found for the "Crafted" file was incomplete and
# in the wrong order.  Reconstruct it from the Items WIKI page.
function write_crafted_list_file()
    open(joinpath(@__DIR__, "Crafted"), "w") do io
        df = CSV.read("src/crafted.csv", DataFrame)
        # Item,Unlock Cost,Sell Price,Material Cost,Time To Craft/s,Used For
        for row in eachrow(df)
            println(io, row["Item"])
        end
    end
end


function fetch_crafted()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, RECIPIE_SOURCE)
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
        CSV.write(joinpath(@__DIR__, "crafted.csv"), df)
        df
    end
end

function make_crafted_recipies()
    df = CSV.read(joinpath(@__DIR__, "crafted.csv"), DataFrame)
    ord = maximum(ordinal, subtypes(Alloy))
    # Item,Unlock Cost,Sell Price,Material Cost,Time To Craft/s,Used For
    for row in eachrow(df)
        ord += 1
        make_thing_code(ord, row, Crafted, "Item", "Material Cost",
                        "Time To Craft/s")
    end
end

