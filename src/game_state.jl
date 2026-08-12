export GameState, add_modifier!


"""
    GameState()

GameState encapsulates the state of the IdlePlanetMiner game.
"""
mutable struct GameState
    planets::OrderedSet{Planet}
    modifiers::Set{Modifier}
    inventory::Inventory

    GameState() = new(OrderedSet{Planet}(),
                      Set{Modifier}(),
                      Inventory()
                      )
end

next_projects(gs::GameState) = next_projects(gs.modifiers)

crafting_plan(gs::GameState) = crafting_plan(gs.inventory, gs.modifiers)


"""
    add_researched_project!(add_this::Type{<:Project}, gs::GameState)

Add `add_this` to the `GqameState` if its prerequisites are met.

Returns the GameStqate.
"""
function add_researched_project!(add_this::Type{<:Project}, gs::GameState)
    function is_present(p::Type{<:Project})
        any(gs.modifiers) do modifier
            modifier isa p
        end
    end
    if is_present(add_this)
        @warn("$add_this is already present.")
        return gs
    end
    satisfied = true
    for p in prerequisites(add_this)
        if !is_present(p)
            @warn("$add_this requires prerequisite $p")
            satisfied = false
        end
    end
    if satisfied
        push!(gs.modifiers, add_this())
    end
    gs
end


"""
    add_planet!(planet::Planet, gs::GameState)

Adds the specified `Planet` to the `GameState` if it is not already present.

Returns the GameState.
"""
function add_planet!(planet::Planet, gs::GameState)
    push!(gs.planets, planet)
    gs
end


"""
    add_modifier!(m::Modifier, gs::GameState)

Adds the specified modifier to the `GameState`.  If the same type of
modifier is already present, it is replaced by the new one.

Returns the GameState.
"""
function add_modifier!(modifier::Modifier, gs::GameState)
    filter!(gs.modifiers) do m
        typeof(m) != typeof(modifier)
    end
    push!(gs.modifiers, modifier)
    gs
end

