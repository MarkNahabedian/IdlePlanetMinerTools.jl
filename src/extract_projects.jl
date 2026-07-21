# Fetch project information from the IdlePlanetMiner WIKI

using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames
using OrderedCollections

include_dependency(joinpath(@__DIR__, "projects.csv"))

export Project, fetch_projects, make_project_definitions

abstract type Project <: Modifier end

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
        println("*** Headings: ", headings)
        df = DataFrame([ h => String[] for h in headings])
        println(df)
        defaults = NamedTuple{Tuple(headings)}(Tuple(map(h -> "", headings)))
        println("*** Defaults ", defaults)
        for table in eachmatch(Cascadia.Selector("table.article-table"), page.root)
            rows = eachmatch(Cascadia.Selector("table.article-table tr"), table)
            column_headings = map(Symbol, map(text, eachmatch(Cascadia.Selector("th"),
                                                              rows[1])))
            for row in rows[2:end]
                tds = eachmatch(Cascadia.Selector("td"), row)
                if length(tds) != length(headings)
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
         factor = 1 / parse(Float32, m["factor"])
         :(spelt_diration_scalar(::$project_type) = factor)
     end),
    # "All planet mine rates x 1.25"
    # "All ship cargo x 1.25"
    (re = r"All crafters speed x ?(?<factor>[0-9.]+)",
     f = function(m::RegexMatch, project_type)
         factor = 1 / parse(Float32, m["factor"])
         :(craft_diration_scalar(::$project_type) = factor)
     end),
    (re = r"Decreases ingredients required by (?<factor>[0-9]+)% for all smelters",
     f = function(m::RegexMatch, project_type)
         factor = 1 - parse(Float32, m["factor"]) / 100
         :(smelt_ingredient_scalar(::$project_type) = factor)
     end),
    (re = r"Decreases ingredients required by (?<factor>[0-9]+)% for all crafters",
     f = function(m::RegexMatch, project_type)
         factor = 1 - parse(Float32, m["factor"]) / 100
         :(craft_ingredient_scalar(::$project_type) = factor)
     end)
]

function make_project_definitions()
    df = CSV.read(joinpath(@__DIR__, "projects.csv"), DataFrame)
    types = []
    recipies = []
    methods = []
    for row in eachrow(df)
        name = Symbol(canonicalize_name(row["Project"]))
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
        # "Advanced Thrusters OR Advanced Cargo Handling"
        prereqs = row["Prerequisite"]
        if prereqs isa AbstractString
            prereqs = map(Symbol, map(canonicalize_name, split(prereqs, " OR ")))
            push!(methods, :(prerequisites(::$name) = $prereqs))
        end
        # effeects:
        desc = row["Text"]
        if desc isa AbstractString
            for (re, f) in ProjectTextToAction
                m = match(re, desc)
                if m isa Nothing
                    continue
                end
                push!(methods, f(m, name))
            end
        end
    end
    #=
    map(println, types)
    map(println, methods)
    map(println, recipies)
    =#
    for t in types
        eval(:(struct $t <: Project end))
        eval(:(export $t))
    end
    map(eval, methods)
    push!(ALL_RECIPIES,
          map(eval, recipies)...)
end

make_project_definitions()

