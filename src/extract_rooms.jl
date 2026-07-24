using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames
using OrderedCollections

export Room, fetch_rooma, base_effect, per_level_effect, max_level

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
    base_effect(typeof(r)) + per_level_effect(typeof(room)) * (r.level - 1)


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

