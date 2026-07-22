export Modifier, DEFAULT_MODIFIERS

export spelt_diration_scalar, craft_diration_scalar,
    smelt_ingredient_scalar, craft_ingredient_scalar

"""
Modifier is the abstract supertype for anything that can modify
various arithmetic factors in the game, for example [`Project`](@ref)s
or `Rooms` that modify smelting ingredients.
"""
abstract type Modifier end

DEFAULT_MODIFIERS = Modifier[]


spelt_diration_scalar(::Modifier) = 1
craft_diration_scalar(::Modifier) = 1
smelt_ingredient_scalar(::Modifier) = 1
craft_ingredient_scalar(::Modifier) = 1

