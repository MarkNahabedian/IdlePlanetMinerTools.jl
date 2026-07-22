# Fetch item information from the IdlePlanetMiner WIKI

using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames

include_dependency(joinpath(@__DIR__, "crafted.csv"))

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
    df = CSV.read(joinpath(@__DIR__, "crafted.csv"), DataFrame)
    # Item,Unlock Cost,Sell Price,Material Cost,Time To Craft/s,Used For
    for row in eachrow(df)
        name1 = row["Item"]
        type = best_thing_match(name1)
        materials = row["Material Cost"]
        duration = row["Time To Craft/s"]
        if isa(duration, AbstractString)
            # "180000s (50h)"
            m = match(r"([0-9,]+)", duration)
            if m == nothing
                @warn("Invalid duration $duration")
                continue
            end
            duration = m.match
            duration = parse(Int, replace(duration, "," => "")) 
        end
        # To make a recipie we add its materials to our supply.  The
        # recipies inputs are diminished and is product is augmented:
        materials = - parse_materials_string(name1, materials)
        push!(recipies, Recipie(type, materials, duration))
    end
    recipies
end

PARSE_MATERIALS_REGEXPS = [
    r"(?<name>[a-zA-Z ]+) [(](?<count>[0-9.]+)(?<suffix>[a-zA-Z]?)[)]",
    r"(?<count>[0-9.]+)(?<suffix>[a-zA-Z]?) (?<name>[a-zA-Z ]+)"
]

PARSE_MATERIALS_MULTIPLIER_SUFFIXES = Dict([
    "" => 1,
    "k" => 1000,
    "K" => 1000])
    
function parse_material(material)
    local m
    for re in PARSE_MATERIALS_REGEXPS
        m = match(re, String(material))    ### match doesn't take SubStrings!
        if m != nothing
            break
        end
    end
    if m == nothing
        error("No match: $name: $material")
    end
    multiplier = PARSE_MATERIALS_MULTIPLIER_SUFFIXES[m["suffix"]]
    type = best_thing_match(m["name"])
    count = multiplier * trunc(Int, parse(Float32, m["count"]))
    type(count)
end


function parse_materials_string(name, materials_string::AbstractString)
    # "Laser (1), Laser Torch (5), Telescope (20), Inside Trader (10), Alchemy (6), Rover Advanced Logistics (10), Advanced Crafter (5), Advanced Item Value (1)"
    # "4 Advanced Teleporters, 400 Luterium Alloy"
    # 5 Copper Bar
    # 10k Palladium Bar
    Inventory(Thing[ parse_material(material)
                     for material in split(materials_string, ", ") ])
end

