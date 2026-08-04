export Process, Mine, Smelt, Craft, Research, to_make,
    process_speed_scalar, process_ingredient_scalar


"""
Process is the abstract supertype for transformative operations.
"""
abstract type Process end

"""
Mine is the subtype of `Process` that generates `Ore`.
"""
struct Mine <: Process end


"""
Smelt is the subtype of Pricess that produces `Alloy`s.
"""
struct Smelt <: Process end


"""
Craft is the subtype of Pricess that produces `Crafted` items.
"""
struct Craft <: Process end


"""
Research is the subtype of `Process` that produces `Project`s.
"""
struct Research <: Process end


"""
    to_make(type)

Returns an instance of the subtype of `Process` that can make an
instance of `type`.
"""
to_make(::Type{<:Ore}) = Mine()
to_make(::Type{<:Alloy}) = Smelt()
to_make(::Type{<:Crafted}) = Craft()
to_make(::Type{<:Project}) = Research()
ty_make(x) = to_make(typeof(x))


"""
    process_speed_scalar(::Process, ::Type{<:Modifier})

Returns the scalar multiplier for the speed of the Process as adjusted
by `Modifier`.
"""
process_speed_scalar(::Process, ::Modifier) = 1


"""
    process_ingredient_scalar(::Process, ::Modifier)

Returns the scalar multiplier for the amount of ingredients required
for the Process as adjusted by `Modifier`.
"""
process_ingredient_scalar(::Process, ::Modifier) = 1


