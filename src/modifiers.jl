export Modifier, DEFAULT_MODIFIERS


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

