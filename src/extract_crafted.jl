# Fetch item information from the IdlePlanetMiner WIKI

using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames

export extract_crafted, make_crafted_recipies

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


function extract_crafted()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, RECIPIE_SOURCE)
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
        CSV.write(joinpath(@__DIR__, "crafted.csv"), df)
        df
    end
end


function make_crafted_recipies()
    recipies = Recipie[]
    df = CSV.read("src/crafted.csv", DataFrame)
    # Item,Unlock Cost,Sell Price,Material Cost,Time To Craft/s,Used For
    for row in eachrow(df)
        name1 = row["Item"]
        materials = row["Material Cost"]
        duration = row["Time To Craft/s"]
        name = eval(Symbol(replace(name1, " " => "")))
        duration = parse(Int, duration)
        materials = parse_materials_string(name1, materials)
        push!(recipies, Recipie(name, materials, duration))
    end
    recipies
end


function parse_materials_string(name, materials_string::AbstractString)
    # "Laser (1), Laser Torch (5), Telescope (20), Inside Trader (10), Alchemy (6), Rover Advanced Logistics (10), Advanced Crafter (5), Advanced Item Value (1)"
    # 5 Copper Bar
    regexps = [
        r"(?<name>[a-zA-Z ]+) [(](?<count>[0-9]+)[)]",
        r"(?<count>[0-9]+) (?<name>[a-zA-Z ]+)"
    ]
    map(split(materials_string, ", ")) do material
        local m
        for re in regexps
            m = match(re, material)
            if m != nothing
                break
            end
        end
        if m == nothing
            error("No match: $name: $material")
        end
        type = eval(Symbol(replace(m["name"], " " => "")))
        count = parse(Int, m["count"])
        type(count)
    end
end

