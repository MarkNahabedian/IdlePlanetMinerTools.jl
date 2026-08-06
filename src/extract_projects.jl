# Fetch project information from the IdlePlanetMiner WIKI

using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames
using OrderedCollections

include_dependency(joinpath(@__DIR__, "projects.csv"))

export fetch_projects, make_project_definitions


PROJECTS_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Projects"

### WHY does the first row have all missing values?
function fetch_projects()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, PROJECTS_SOURCE)
        # First collect all column names:
        headings = OrderedSet()
        for table in eachmatch(Cascadia.Selector("table.article-table"), page.root)
            row1 = first(eachmatch(Cascadia.Selector("table.article-table tr"), table))
            push!(headings, map(text, eachmatch(Cascadia.Selector("th"), row1))...)
        end
        headings = collect((Symbol(h) for h in headings))
        df = DataFrame([ h => String[] for h in headings])
        defaults = NamedTuple{Tuple(headings)}(Tuple(map(h -> "", headings)))
        for table in eachmatch(Cascadia.Selector("table.article-table"), page.root)
            rows = eachmatch(Cascadia.Selector("table.article-table tr"), table)
            column_headings = map(Symbol, map(text, eachmatch(Cascadia.Selector("th"),
                                                              rows[1])))
            for row in rows[2:end]
                tds = eachmatch(Cascadia.Selector("td"), row)
                if length(tds) != length(column_headings)
                    println("skipping tr for $(length(headings)) $(length(tds)) )$tds.")
                    continue
                end
                data = map(text, tds)
                push!(df,
                      merge(defaults,
                            map(x -> x[1] => x[2], zip(column_headings, data))))
            end
        end
        CSV.write(joinpath(@__DIR__, "projects.csv"), df)
        df
    end
end

ProjectTextToAction = [
    (re = r"All smelters speed x ?(?<factor>[0-9.]+)",
     f = function(m::RegexMatch, project_type)
         factor = parse(Float32, m["factor"])
         :(process_speed_scalar(::Smelt, ::$project_type) = factor)
     end),
    # "All planet mine rates x 1.25"
    # "All ship cargo x 1.25"
    (re = r"All crafters speed x ?(?<factor>[0-9.]+)",
     f = function(m::RegexMatch, project_type)
         factor = parse(Float32, m["factor"])
         :(process_speed_scalar(::Craft, ::$project_type) = factor)
     end),
    (re = r"Decreases ingredients required by (?<factor>[0-9]+)% for all smelters",
     f = function(m::RegexMatch, project_type)
         factor = 1 - parse(Float32, m["factor"]) / 100
         :(process_ingredient_scalar(::Smelt, ::$project_type) = $factor)
     end),
    (re = r"Decreases ingredients required by (?<factor>[0-9]+)% for all crafters",
     f = function(m::RegexMatch, project_type)
         factor = 1 - parse(Float32, m["factor"]) / 100
         :(process_ingredient_scalar(::Craft, ::$project_type) = $factor)
     end)
]

function make_project_definitions()
    df = CSV.read(joinpath(@__DIR__, "projects.csv"), DataFrame)
    types = []
    docstrings = Dict()
    recipies = []
    prqs = []
    methods = []
    for row in eachrow(df)
        name = Symbol(canonicalize_name(row["Project"]))
        docstrings[name] = row["Text"]
        # The Project itself:
        push!(types, name)
        # its Recipie:
        cost = row["Cost"]
        if cost isa AbstractString
            push!(recipies,
                  :(Recipie($name,
                            $(parse_materials_string(name, cost)),
                            0)))
        end
        # Prerequisites:
        prereqs = row["Prerequisite"]
        if prereqs isa AbstractString
            if occursin(" OR ", prereqs)
                # "Advanced Thrusters OR Advanced Cargo Handling"
                prereqs = map(Symbol, map(canonicalize_name,
                                          split(prereqs, " OR ")))
                push!(prqs, name => prereqs)
            elseif occursin(" & ", prereqs)
                # Telescope 3 & Surge Branch 1 node
                # Maybe we need conjunction for this.  I don't
                # understand surges yet.  We'll burn that bridge when
                # we come to it.
                s = split(prereqs, " & ")
                prereqs = [Symbol(canonicalize_name(s[1]))]
                println("Ignoring $(s[2]) in $prereqs")
                push!(prqs, name => prereqs)
            elseif nothing != match(r"Surge Branch (?<num>[0-9]*) node",
                                    prereqs)
                println("Ignoring $prereqs")
                # ignore for now
            else
                push!(prqs, name => [Symbol(canonicalize_name(prereqs))])
            end
        end
        # effeects:
        desc = row["Text"]
        if desc isa AbstractString
            for (re, f) in ProjectTextToAction
                m = match(re, desc)
                if m isa RegexMatch
                    push!(methods, f(m, name))
                end
            end
        end
    end
    #=
    map(println, types)
    map(println, methods)
    map(println, recipies)
    =#
    for t in types
        eval(quote
                 struct $t <: Project end
                 @doc $(docstrings[t]) $t
             end)
        eval(:(export $t))
    end
    for pair in prqs
        typ(sym::Symbol) = eval(sym)  # getfield(IdlePlanetMinerTools, sym)
        t1 = typ(first(pair))
        prereqs = map(typ, last(pair))
        eval(:(prerequisites(::Type{$t1}) = $prereqs))
    end
    map(eval, methods)
    push!(ALL_RECIPIES,
          map(eval, recipies)...)
end

make_project_definitions()

# Telescope 24 is not on the wiki page:
struct Telescope24 <: Project end
@doc "Extends vision to planets 74 - 76" Telescope24
prerequisites(::Telescope24) = [Telescope23]
Recipie(Telescope24,
        Teleporter(5) + AqualiteAlloy(21),
        0)
export Telescope24

