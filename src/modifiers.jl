using Markdown

export Modifier, NoAdsMineBoots, DEFAULT_MODIFIERS, doctext


"""
Modifier is the abstract supertype for anything that can modify
various arithmetic factors in the game, for example [`Project`](@ref)s
or `Rooms` that modify smelting ingredients.
"""
abstract type Modifier end


"""
NoAdsMineBoots is the modifier that provides a 1.2 increase in mining
rate when you pay for no ads.
"""
struct NoAdsMineBoots <: Modifier
end


"""
DEFAULT_MODIFIERS is the list of Modifiers that is used for operations
like [`delta`](@ref)where none are specified.
"""
DEFAULT_MODIFIERS = Modifier[]


"""
    doctext(::Type{<:Modifier})

Returns a text string defining the Modifier.
"""
doctext(m::Type{<:Modifier}) = chomp(Markdown.plain(Docs.doc(m).content[1]))
