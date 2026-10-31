using Pkg
Pkg.activate(; temp = true)
Pkg.add("Documenter")
using Documenter
using Markdown

Pkg.activate(joinpath(dirname(dirname(@__FILE__)), "Project.toml"))

using IdlePlanetMinerTools

DocMeta.setdocmeta!(IdlePlanetMinerTools, :DocTestSetup, :(using IdlePlanetMinerTools); recursive=true)

makedocs(;
    modules=[IdlePlanetMinerTools],
    authors="MarkNahabedian <naha@mit.edu> and contributors",
    sitename="IdlePlanetMinerTools.jl",
    format=Documenter.HTML(;
        canonical="https://MarkNahabedian.github.io/IdlePlanetMinerTools.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Appendicies" => [
            "Planets" => "planets.md",
            "Ores" => "ores.md",
            "Alloys" => "alloys.md",
            "Crafted Items" => "crafted.md"
        ]
    ],
)

deploydocs(;
    repo="github.com/MarkNahabedian/IdlePlanetMinerTools.jl",
    devbranch="main",
)
