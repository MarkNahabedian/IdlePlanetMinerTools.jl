export CraftingAction, crafting_plan

struct CraftingAction
    recipie::Recipie
    count::Int
end

"""
    crafting_plan(inv::Inventory)

Appliies `Recipie`s to the ~Inventory` until there are no negative
item counts or there is no known recipie to resolve the current
shortage.

Returns a list of `CraftingAction`s and the final `Inventory`.
"""
function crafting_plan(inv::Inventory)
    actions = CraftingAction[]
    inventory = inv
    while true
        # Find the Thing in inventory that has a negative count and the greatest ordinal.
        need = filter(i -> i.count < 0, inventory.items)
        if isempty(need)
            break
        end
        # find its recipie
        need = last(need)
        recipie = filter(r -> r.make == typeof(need), ALL_RECIPIES)
        if isempty(recipie)
            break
        end
        recipie = first(recipie)
        # Apply the recipie enough times
        multiplier = - need.count
        pushfirst!(actions, CraftingAction(recipie, multiplier))
        inventory += multiplier * delta(recipie)
    end
    actions, inventory
end

