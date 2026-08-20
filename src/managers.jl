
export Manager


"""
    Manager(stars::Int, name::AbstractString; mine_rate::Float32 ship_speed::Float32 cargo::Float32 all_mine_rate::Float32 all_ship_speed::Float32 all_cargo::Float32 all_smelt_speed::Float32 all_craft_speed::Float32)

`Manager` represents a manager.  `Manager is a subtype of [`Modifier`](@ref).
"""
struct Manager <: Modifier
    stars::Int
    name::AbstractString
    mine_rate::Float32
    ship_speed::Float32
    cargo::Float32
    all_mine_rate::Float32
    all_ship_speed::Float32
    all_cargo::Float32
    all_smelt_speed::Float32
    all_craft_speed::Float32

    Manager(stars::Int, name::AbstractString;
            mine_rate=Float32(1), ship_speed=Float32(1), cargo=Float32(1),
            all_mine_rate=Float32(1), all_ship_speed=Float32(1),
            all_cargo=Float32(1),
            all_smelt_speed=Float32(1),
            all_craft_speed=Float32(1)) =
                new(stars, name,
                    mine_rate, ship_speed, cargo,
                    all_mine_rate, all_ship_speed, all_cargo,
                    all_smelt_speed, all_craft_speed)
end

process_speed_scalar(::Mine, m::Manager) = m.all_mine_rate

process_speed_scalar(::Transport, m::Manager) = m.all_ship_speed

process_capacity_scalar(::Transport, m::Manager) = m.all_cargo

process_speed_scalar(::Smelt, m::Manager) = m.all_smelt_speed

process_speed_scalar(::Craft, m::Manager) = m.all_craft_speed

