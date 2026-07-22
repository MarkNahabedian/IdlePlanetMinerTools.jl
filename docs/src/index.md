```@meta
CurrentModule = IdlePlanetMinerTools
```

# IdlePlanetMinerTools

Documentation for [IdlePlanetMinerTools](https://github.com/MarkNahabedian/IdlePlanetMinerTools.jl).

This package provides some tools for thise who play the TechTree game Idle Planet Miner.


```@contents
```

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


## Recipies

A [`Recipie`](@ref) describes how to smelt an [`Ore]((@ref) to an
[`Alloy`](@ref), an `Alloy` to a [`Crafted`](@ref) item or to create a
[`Project`](@ref) from such things.

You can lookup a recipie using an `rx` string:

```@example
using IdlePlanetMinerTools

rx"LaserTorch"

rx"Advanced Crafter"
````


## Arithmetic

Arithmetic operations are defined for `Thing`s and `Inventory`s:


```@example
using IdlePlanetMinerTools

need = 7 * delta(rx"gravity chamber")

have = GravityChamber(4) + AdvancedComputer(42) + BasicComputer(64) + Circuit(902)

actions, result = crafting_plan(have - need)
```


## Projects

Once you reasearch a [`Project`](@ref) the game improves on your
capabilities or gives you access to additional functionality.  Each
`Project` has a [`Recipie`](@ref) that describes what you need to be
able to reasearch it.  Most `Project`s also have
[`prerequisites`](@ref) which are other projects that you need to have
reasearched beforehand.

Once you've researched a project, you should add it to
[`DEFAULT_MODIFIERS`](@ref) so that its benefits will be used
throughout this package.


## Modifiers

During the course of the game, the player may accumulate status that
alters calculations.  Among these are [`Project`](@ref)s, `Manager`s
and space ship `Room`s.  Each of these is a kind of `Modifier`.
[`DEFAULT_MODIFIERS`](@ref) is a list of modifiers that the player has
said they already have.  It is used by [`delta`](@ref) to determine
what is needed to complete a [`Recipie`](@ref) if another list of
`Modifier`s is not passed to it.


## Index

```@index
```


## Definitions

```@autodocs
Modules = [IdlePlanetMinerTools]
```
