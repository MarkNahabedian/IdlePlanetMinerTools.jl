# Extract alloy definitions.

using WebScrapingTools
using Cascadia
using Gumbo
using CSV
using DataFrames

include_dependency(joinpath(@__DIR__, "alloys.csv"))

export extract_alloys

PROJECTS_SOURCE = "https://idle-planet-miner.fandom.com/wiki/Alloys"


function extract_alloys()
    with_webdriver_session(FirefoxGeckodriverSession()) do session
        page = fetch_page(session, PROJECTS_SOURCE)
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
        CSV.write(joinpath(@__DIR__, "alloys.csv"), df)
        df
    end
end


extract_alloys()

