using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames

# In order to be able to use best_thing_match on the input materials
# list, we need for each Thing to be fully defined before any
# following Things.


PARSE_MATERIALS_REGEXPS = [
    r"(?<name>[a-zA-Z ]+) [(](?<count>[0-9.]+)(?<suffix>[a-zA-Z]?)[)]",
    r"(?<count>[0-9.]+)(?<suffix>[a-zA-Z]?) (?<name>[a-zA-Z ]+)"
]

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


function make_thing_code(ordinal::Int, row, supertype,
                         name_column_heading::AbstractString,
                         inputs_column_heading::Union{Nothing, AbstractString},
                         duration_column_heading::Union{Nothing, AbstractString}
                         )
    name1 = row[name_column_heading]
    type = Symbol(canonicalize_name(name1))
    eval(:(export $type))
    eval(:(struct $type <: $supertype
               count::Real
               $type(count) = new(round(count, digits=3))
           end))
    eval(:(ordinal(::Type{$type}) = $ordinal))
    define_base_selling_price_method(type, row["Sell Price"])
    if duration_column_heading isa AbstractString
        duration = row[duration_column_heading]
        if isa(duration, AbstractString)
            # "180000s (50h)"
            m = match(r"([0-9,]+)", duration)
            if m == nothing
                @warn("Invalid duration $duration")
                return
            end
            duration = m.match
            duration = parse(Int, replace(duration, "," => "")) 
        end
    end
    if inputs_column_heading isa AbstractString
        materials = row[inputs_column_heading]
        materials = invokelatest(-, invokelatest(parse_materials_string, name1, materials))
        push!(ALL_RECIPIES, Recipie(invokelatest(eval, type),
                                    materials, duration))
    end
end

