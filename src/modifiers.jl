export Modifier, DEFAULT_MODIFIERS

export smelt_speed_scalar, craft_speed_scalar,
    smelt_ingredient_scalar, craft_ingredient_scalar

"""
Modifier is the abstract supertype for anything that can modify
various arithmetic factors in the game, for example [`Project`](@ref)s
or `Rooms` that modify smelting ingredients.
"""
abstract type Modifier end

"""
DEFAULT_MODIFIERS is the list of Modifiers that is used for operations
like [`delta`](@ref)where none are specified.
"""
DEFAULT_MODIFIERS = Modifier[]


smelt_speed_scalar(::Modifier) = 1
craft_speed_scalar(::Modifier) = 1
smelt_ingredient_scalar(::Modifier) = 1
craft_ingredient_scalar(::Modifier) = 1

