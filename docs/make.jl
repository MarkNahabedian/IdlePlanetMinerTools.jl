using IdlePlanetMinerTools
using Documenter

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
    ],
)

deploydocs(;
    repo="github.com/MarkNahabedian/IdlePlanetMinerTools.jl",
    devbranch="main",
)
