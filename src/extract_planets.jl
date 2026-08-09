
export Planet, fetch_planets, make_planet_definitions, ALL_PLANETS,
    find_planet, @pl_str, provides_ore

include_dependency(joinpath(@__DIR__, "planets.csv"))

PLANETS_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Planets"

"""
OreYield represents one of a Planet's ore yields.
"""
struct OreYield
    ore::Type{<:Ore}
    yield::Float32
end

provides_ore(oy::OreYield, o::Type{<:Ore}) = oy.ore == o


"""
Planet represents a Planet.
"""
struct Planet
    number::Int
    name::String
    base_price::Float32
    telescope::Union{Nothing, Type{<:Project}}
    ores::Vector{OreYield}
end

namestring(p::Planet) = p.name

provides_ore(p::Planet, o::Type{<:Ore}) =
    any(oy -> provides_ore(oy, o), p.ores)


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

ALL_PLANETS = Planet[]

find_planet(planet::Int) =
    only(filter(ALL_PLANETS) do p
             p.number == planet
         end)

function find_planet(planet::AbstractString)
    m = match(r"[0-9]+", planet)
    # Name or number?
    if m isa RegexMatch
        number = parse(Int, m.match)
        return find_planet(number)
    end
    return best_thing_match(planet, ALL_PLANETS)
end

macro pl_str(planet)
    return :(find_planet($planet))
end


function make_planet_definitions()
    df = CSV.read(joinpath(@__DIR__, "planets.csv"), DataFrame)
    this_planet = nothing
    this_planet_ore_yields = OreYield[]
    function make_ore_yield(row)
        ore = row["Resources"]
        ore = only(filter(subtypes(Ore)) do o
                       string(nameof(o)) == ore ||
                           (ore == "Silica"  && o == Silicon) ||
                           (ore == "Aluminium" && o == Aluminum)
                   end)
        yield = row["Yield (%)"]
        m = match(r"[0-9]+", yield)
        yield = parse(Float32, m.match) / 100
        push!(this_planet_ore_yields, OreYield(ore, yield))
    end
    function finish_planet()
        telescopenum = this_planet["Telescope Number"]
        if telescopenum == "Default"
            telescope = nothing
        else
            ts = "Telescope$(parse(Int, telescopenum))"
            telescope = only(filter(all_projects()) do p
                                 string(nameof(p)) == ts
                             end)
        end
        num = this_planet["No."]
        name = this_planet["Planet"]
        price = parse_selling_price(this_planet["Base Price"])
        ore_yields = this_planet_ore_yields
        push!(ALL_PLANETS, Planet(num, name, price, telescope, ore_yields))
        this_planet_ore_yields = OreYield[]
        this_pllanet = nothing
    end
    for row in eachrow(df)
        if this_planet != nothing && row["No."] == this_planet["No."]
            # Same planet as previous row
            make_ore_yield(row)
        else
            # new planet
            if this_planet != nothing
                finish_planet()
            end
            this_planet = row
            make_ore_yield(row)
        end
    end
    @assert !isempty(this_planet_ore_yields)
    finish_planet()
end


