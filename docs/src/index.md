```@meta
CurrentModule = IdlePlanetMinerTools
```

# IdlePlanetMinerTools

Documentation for [IdlePlanetMinerTools](https://github.com/MarkNahabedian/IdlePlanetMinerTools.jl).


## Things and Inventory

Mining, smelting and crafting produce instances of subtypes of `Ore`,
`Alloy`, or `Crafted`, respectively.  These are all subtypes of
`Thing`.  Each concrete subtype of `Thing` has a `count` field
indicating a quantity of that `Thing`.

One can make a Thing using a concrete constructor

```@example things
using IdlePlanetMinerTools

Battery(3)
```

or using the `@t_str` macro, which makes the named thing with a count of 1.

```@example things
t"battery"
```

Note that for convenience, `@t_str` uses a dictionary of all concrate
`Thing` subtypes and finds the closest string match.


An `Inventory` represents a collection of disperate `Thing`s.

For convenience, there is a total ordering defined on all concrete
subtypes of [`Thing`](@ref).


## Arithmetic

Arithmetic operations are defined for `Thing`s and `Inventory`s:


```@example
using IdlePlanetMinerTools

need = 7 * delta(rx"gravity chamber")

have = GravityChamber(4) + AdvancedComputer(42) + BasicComputer(64) + Circuit(902)

actions, result = crafting_plan(have - need)
```


## Index

```@index
```


## Definitions

```@autodocs
Modules = [IdlePlanetMinerTools]
```
