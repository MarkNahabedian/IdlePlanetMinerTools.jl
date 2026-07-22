

Base.:(==)(a::T, b::T) where T <: Thing = a.count == b.count

Base.:(==)(a::Inventory, b::Inventory) = a.items == b.items

Base.:*(i::Real, t::Thing) = typeof(t)(i * t.count)
Base.:*(t::Thing, i::Real) = typeof(t)(i * t.count)
Base.:*(i::Real, inv::Inventory) =
    Inventory([ i * item for item in inv.items ])
Base.:*(inv::Inventory, i::Real) =
    Inventory([ i * item for item in inv.items ])

function Base.:+(a::T, b::T) where T <: Thing
    typeof(a)(a.count + b.count)
end

Base.:+(a::Thing, b::Thing) = Inventory(a) + Inventory(b)
Base.:+(a::Thing, b::Inventory) = Inventory(a) + b
Base.:+(a::Inventory, b::Thing) = a + Inventory(b)
Base.:+(inv1::Inventory, inv2::Inventory) =
    Inventory(Thing[inv1.items..., inv2.items...])

Base.:-(a::Thing) = typeof(a)(- a.count)
Base.:-(a::Thing, b::Thing) = a + -b
Base.:-(inv::Inventory) = -1 * inv
Base.:-(inv1::Inventory, inv2::Inventory) = inv1 + (-1 * inv2)
Base.:-(inv::Inventory, thing::Thing) = inv - Inventory(thing)
Base.:-(thing::Thing, inv::Inventory) = Inventory(thing) - inv

