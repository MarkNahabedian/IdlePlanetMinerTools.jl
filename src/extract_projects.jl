# Fetch project information from the IdlePlanetMiner WIKI

using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames
using OrderedCollections

# include_dependency(joinpath(@__DIR__, "crafted.csv"))

export Project, extract_projects, make_project_definitions

abstract type Project <: Modifier end

PROJECTS_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Projects"


function extract_projects()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, PROJECTS_SOURCE)
        # First collect all column names:
        headings = OrderedSet()
        for table in eachmatch(Cascadia.Selector("table.article-table"), page.root)
            row1 = first(eachmatch(Cascadia.Selector("table.article-table tr"), table))
            push!(headings, map(text, eachmatch(Cascadia.Selector("th"), row1))...)
        end
        headings = collect((Symbol(h) for h in headings))
        println(headings)
        df = DataFrame([ h => String[] for h in headings])
        println(df)
        defaults = NamedTuple{Tuple(headings)}(Tuple(map(h -> "", headings)))
        println(defaults)
        for table in eachmatch(Cascadia.Selector("table.article-table"), page.root)
            rows = eachmatch(Cascadia.Selector("table.article-table tr"), table)
            column_headings = map(Symbol, map(text, eachmatch(Cascadia.Selector("th"),
                                                              rows[1])))
            for row in rows[2:end]
                tds = eachmatch(Cascadia.Selector("td"), row)
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


