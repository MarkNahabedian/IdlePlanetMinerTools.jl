

Base.:(==)(a::T, b::T) where T <: Thing = a.count == b.count

function Base.:+(a::T, b::T) where T <: Thing
    typeof(a)(a.count + b.count)
end

Base.:-(a::Thing) = typeof(a)(- a.count)

function Base.:-(a::T, b::T) where T <: Thing
    typeof(a)(a.count - b.count)
end

Base.:*(f::Int, t::Thing) = typeof(t)(f * t.count)

Base.:+(a::Thing, b::Vector{Thing}) = Thing[a] + b
Base.:+(a::Vector{Thing}, b::Thing) = Thing[a] + b
Base.:+(a::Thing, b::Thing) = Thing[a] + Thing[b]

function Base.:+(a::Vector{Thing}, b::Vector{Thing})
    ab = sort([a..., b...]; by = ordinal)
    s = Thing[first(ab)]
    for i in ab[2:end]
        if typeof(i) === typeof(last(s))
            s[lastindex(s)] = typeif(i)(i.count + s[lastindex(s)].count)
        else
            push!(s, i)
        end
    end
    s
end
    
