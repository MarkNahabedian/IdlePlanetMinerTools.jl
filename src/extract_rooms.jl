using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames
using OrderedCollections

export Room, fetch_rooma, base_effect, per_level_effect, max_level,
    extract_rooms

include_dependency(joinpath(@__DIR__, "rooms.csv"))

ROOMS_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Rooms"


"""
Room is the abstract supertype for all space ship rooms.  Each room
has a `level` field.

Associated with each Room type is a `base_effect` and a `per_level_effect`,
and a `max_level`.
"""
abstract type Room <: Modifier end


"""
    base_effect(::Type{<:Room})

Returns the modifier factor for the room type at level 1.
"""
function base_effect #= (::Type{<:Room}) =# end


"""
    per_level_effect(::Type{<:Room})

Returns the modifier factor for the room type for each level above
level 1.
"""
function per_level_effect #= (::Type{<:Room}) =# end


"""
    max_level(::Type{<:Room})

Returns the maximum allowed value for the `level` field for the
specified room type.
"""
function max_level #= (::Type{<:Room}) =# end
    

"""
    room_effect_factor(::Room)

Computes the effect factor for the Room based on its type and level.
This says nothing about what is modified.  It just represents a
calculation that tis common to all rooms.
"""
room_effect_factor(r::Room) =
    base_effect(typeof(r)) + per_level_effect(typeof(r)) * (r.level - 1)


function fetch_rooma()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, ROOMS_SOURCE)
        table = only(eachmatch(Cascadia.Selector("table.article-table"), page.root))
        rows = eachmatch(Cascadia.Selector("table.article-table tr"), table)
        # First row is headings.
        column_headings = map(text, eachmatch(Cascadia.Selector("th"), rows[1]))
        df = DataFrame([ h => String[] for h in column_headings ])
        for row in rows[2:end]
            tds = eachmatch(Cascadia.Selector("td"), row)
            data = map(text, tds)
            push!(df, data)
        end
        CSV.write(joinpath(@__DIR__, "rooms.csv"), df)
        df
    end
end

ROOM_BOOST_TO_GENERIC_FUNCTION = Dict([
    "Increase smelt speed" => :smelt_duration_scalar,
    "Increase craft speed" => :craft_duration_scalar,
    "Decrease smelter ingredients" => :smelt_ingredient_scalar,
    "Decrease crafter ingredients" => :craft_ingredient_scalar
])


function parse_base_effect(s::AbstractString)
    # "x1.25", "x90%", "+0:30", "T0", "-"
    if s in ["T0", "-"]
        return nothing
    end
    m = match(r"^x(?<factor>[0-9.]+)$", s)
    if m isa RegexMatch
        return parse(Float32, m["factor"])
    end
    m = match(r"^x(?<pct>[0-9]+)%$", s)
    if m isa RegexMatch
        return parse(Float32, m["pct"]) / 100
    end
    m = match(r"^[+](?<hour>[0-9]+):(?<minute>[0-9]+)$", s)
    if m isa RegexMatch
        return parse(Int, m["hour"]) * 60 + parse(Int, m["minute"])
    end
    error("Unrecognized room base effect: \"$s\".")
end

function parse_per_level(s::AbstractString)
    # "+.15", "- 4%", "+0:30", "-"
    if s == "-"
        return nothing
    end
    m = match(r"^[+](?<factor>[0-9.]+)$", s)
    if m isa RegexMatch
        return parse(Float32, m["factor"])
    end
    m = match(r"^- (?<pct>[0-9]+)%$", s)
    if m isa RegexMatch
        return - parse(Float32, m["pct"]) / 100
    end
    m = match(r"^[+](?<hour>[0-9]+):(?<minute>[0-9]+)$", s)
    if m isa RegexMatch
        return parse(Int, m["hour"]) * 60 + parse(Int, m["minute"])
    end
    error("Unrecognized room base effect: \"$s\".")
end

function parse_room_max_level(s::AbstractString)
    if s == "-"
        typemax(Int32)
    else
        parse(Int, s)
    end
end


function extract_rooms()
    df = CSV.read(joinpath(@__DIR__, "rooms.csv"), DataFrame)
    # Room,Boost,Min Cost,CombinedMin Cost,BaseEffect,Per Level,Max Level,Max Bonus
    for row in eachrow(df)
        name = Symbol(canonicalize_name(row["Room"]))
        boost = get(ROOM_BOOST_TO_GENERIC_FUNCTION, row["Boost"], nothing)
        base = parse_base_effect(row["BaseEffect"])
        per_level = parse_per_level(row["Per Level"])
        max_level = parse_room_max_level(row["Max Level"])
        eval(:(begin
                   export $name
                   struct $name <: Room
                       level::Int
                       function $name(level::Int)
                           if level < 1 || level > $max_level
                               error("Max level for $name is $max_level")
                           end
                           new(level)
                       end
                   end
                   base_effect(::Type{$name}) = $base
                   per_level_effect(::Type{$name}) = $per_level
                   max_level(::Type{$name}) = $max_level
               end
               ))
        if boost != nothing
            eval(:($boost(room::$name) = room_effect_factor(room)))
        end
    end
end

extract_rooms()

