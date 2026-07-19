```@meta
CurrentModule = IdlePlanetMinerTools
```

# IdlePlanetMinerTools

Documentation for [IdlePlanetMinerTools](https://github.com/MarkNahabedian/IdlePlanetMinerTools.jl).

```@example
using IdlePlanetMinerTools

need = 7 * rx"gravity chamber".delta

have = GravityChamber(4) + AdvancedComputer(42) + BasicComputer(64) + Circuit(902)

actions, result = crafting_plan(have - need)
```


```@index
```

```@autodocs
Modules = [IdlePlanetMinerTools]
```
