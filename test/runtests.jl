using IdlePlanetMinerTools
using Test
using InteractiveUtils

@testset "arithmetic" begin
    @test t"Iron" + 2 * t"Iron" == 3 * t"Iron"
    @test t"Silver" + t"Gold" == Inventory(t"Silver", t"Gold")
    @test -(Aluminum(2) - Platinum(1)) == Inventory(Aluminum(-2), Platinum(1))
    @test (2 * t"Iron" + t"Silicon") + (Silicon(4) + Copper(2)) ==
        Inventory(Copper(2), Iron(2), Silicon(5))
    @test t"Gold Bar" - 3 * t"Lead Bar" ==
        Inventory(LeadBar(-3), GoldBar(1))
    @test GravityChamber(4) + AdvancedComputer(29) + BasicComputer(23) + Circuit(1290) ==
        Inventory(GravityChamber(4), AdvancedComputer(29), BasicComputer(23), Circuit(1290))
end

@testset "object counts" begin
    @test length(subtypes(Ore)) == 27
    @test length(subtypes(Alloy)) == 28
    @test length(subtypes(Crafted)) == 44
    @test length(all_projects()) == 126    # Telescope24 added by hand
    @test length(ALL_RECIPIES) ==  198     # Telescope24
    @test length(subtypes(Room)) == 22
end

@testset "recipie ingredient modifiers" begin
    r = rx"PlatinumBar"
    @test delta(r, []) ==
        Platinum(-1000.0) + GoldBar(-2.0) + PlatinumBar(1)
    @test delta(r, [SmeltingEfficiency()]) ==
        Platinum(-800.000) + GoldBar(-1.600) + PlatinumBar(1)
end

@testset "project prerequisites" begin
    @test prerequisites(rx"Asteroid Miner".make) == []
    @test prerequisites(rx"Rover".make) == [AsteroidMiner]
    @test Set(prerequisites(rx"superior mining".make)) ==
        Set([AdvancedThrusters, AdvancedCargoHandling])
end

@testset "project modifiers" begin
    @test isapprox(process_ingredient_scalar(Smelt(), SmeltingEfficiency()), 0.8)
    @test isapprox(process_ingredient_scalar(Craft(), SmeltingEfficiency()), 1.0)
    @test isapprox(process_ingredient_scalar(Research(), SmeltingEfficiency()), 1.0)
    @test isapprox(process_ingredient_scalar(Smelt(), CraftingEfficiency()), 1.0)
    @test isapprox(process_ingredient_scalar(Craft(), CraftingEfficiency()), 0.8)
    @test isapprox(process_ingredient_scalar(Research(), CraftingEfficiency()), 1.0)
    @test isapprox(process_ingredient_scalar(Smelt(), Management()), 1.0)
    @test isapprox(process_ingredient_scalar(Craft(), Management()), 1.0)
    @test isapprox(process_ingredient_scalar(Research(), Management()), 1.0)
end

@testset "room modifiers" begin
    @test isapprox(process_ingredient_scalar(Smelt(), Robotics(3)), 1)
    @test isapprox(process_ingredient_scalar(Smelt(), Underforge(3)), 0.82)
    @test isapprox(process_ingredient_scalar(Craft(), Engineering(2)), 1)
    @test isapprox(process_ingredient_scalar(Craft(), Dorm(4)), 0.78)
    @test isapprox(process_speed_scalar(Smelt(), Engineering(2)), 1)
    @test isapprox(process_speed_scalar(Smelt(), Forge(3)), 1.4)
    @test isapprox(process_speed_scalar(Craft(), Astronomy(2)), 1)
    @test isapprox(process_speed_scalar(Craft(), Workshop(4)), 1.5)
end

@testset "add_researched_project" begin
    have = Modifier[Management(), Telescope1()]
    l1 = length(have)
    add_researched_project!(Telescope5, have)
    @test length(have) == l1 + 4
end

@testset "process_ingredient_scalar spot check" begin
    # This test was taken from an early set of game state calculations.
    modifiers = Modifier[
        # Rooms:
        Engineering(8), Aeronautical(5), Packaging(5), Forge(7),
        Workshop(7), Astronomy(2), Laboratory(3), Terrarium(4), Lounge(5),
        BackupGenerator(2), Underforge(4)
    ]
    # Projects:
    add_researched_project!(SuperiorFurnace, modifiers)
    add_researched_project!(PreferredVendor, modifiers)
    add_researched_project!(SmeltingSpecialist, modifiers)
    add_researched_project!(AdvancedAlloyValue, modifiers)
    add_researched_project!(ColonizationEfficiency, modifiers)
    add_researched_project!(ColonyAdvancedTaxIncentives, modifiers)
    add_researched_project!(ColonizationSuperiorScouting, modifiers)
    add_researched_project!(AsteroidHarvester, modifiers)
    add_researched_project!(RoverScanningModule, modifiers)
    add_researched_project!(RoverResupply, modifiers)
    add_researched_project!(Telescope8, modifiers)
    add_researched_project!(OreTargeting, modifiers)
    add_researched_project!(BottleneckOptimizations, modifiers)
    add_researched_project!(Beacon, modifiers)
    add_researched_project!(SuperiorThrusters, modifiers)
    add_researched_project!(SuperiorCargoHandling, modifiers)
    add_researched_project!(CraftingSpecialist, modifiers)
    add_researched_project!(CraftingEfficiency, modifiers)
    add_researched_project!(AsteroidAutoMiner, modifiers) 
    add_researched_project!(PreferredVendor, modifiers)
    add_researched_project!(Terraforming, modifiers)
    add_researched_project!(InsideTrader, modifiers)
    add_researched_project!(SuperiorAlloyValue, modifiers)
    add_researched_project!(Telescope9, modifiers)
    add_researched_project!(ManagerTraining, modifiers)
    add_researched_project!(SuperiorCrafting, modifiers)
    function rnd(i::Inventory)
        Inventory([
            typeof(item)(round(Int, item.count))
            for item in i.items])
    end
    @test rnd(delta(rx"Alchemy", modifiers)) ==
        GoldBar(41) + Lens(5)
    @test rnd(delta(rx"ColonyRenegotiation", modifiers)) ==
        BronzeBar(82) + Hammer(328)
    @test rnd(delta(rx"ContractManager", modifiers)) ==
        TitaniumBar(20) + Circuit(16) + BasicComputer(16)
    @test rnd(delta(rx"Telescope10", modifiers)) ==
        PalladiumBar(8) + ThermalScanner(2)
    @test rnd(delta(rx"ColonySuperiorTaxIncentives", modifiers)) ==
        Inventory(PalladiumBar(49))
    @test rnd(delta(rx"AdvancedManagerTraining", modifiers)) ==
        AdvancedBattery(8) + AdvancedComputer(2)
    @test rnd(delta(rx"ColonizationSuperiorEfficiency", modifiers)) ==
        PalladiumBar(41) + LaserTorch(12)
    @test rnd(delta(rx"FurnaceOverdrive", modifiers)) ==
        OsmiumBar(16) + PlasmaTorch(1)
    @test rnd(delta(rx"AdvancedOreTargeting", modifiers)) ==
        BasicComputer(82) + ThermalScanner(12)
    @test rnd(delta(rx"MarketManipulation", modifiers)) ==
        Diamond(24600) + GoldBar(12300) + BasicComputer(8)
    @test rnd(delta(rx"SuperiorItemValue", modifiers)) ==
        PalladiumBar(164) + LaserTorch(20)
    @test rnd(delta(rx"AsteroidScanner", modifiers)) ==
        ThermalScanner(25) + NavigationModule(4)
    @test rnd(delta(rx"AdvancedRoverResupply", modifiers)) ==
        RhodiumBar(20) + AdvancedBattery(8) + PlasmaTorch(5)
    @test rnd(delta(rx"MarketAccelerator", modifiers)) ==
        IridiumBar(328) + Motor(1)
    @test rnd(delta(rx"AdvancedTerraforming", modifiers)) ==
        Inventory(SatelliteDish(8))
    @test rnd(delta(rx"AdvancedAsteroidHarvester", modifiers)) ==
        PlasmaTorch(41) + SpaceProbe(1)
end

@testset "Project doc strings" begin
    @test doctext(Management) == "Hire and assign managers to planets"
end

@testset "project grid coordinates" begin
    # only one project at a given grid location.
    grid = Dict{Tuple{Int, Int}, Type{<:Project}}()
    for (p, c) in PROJECT_CHART_COORDINATES
        if c == ()
            # We don't know grid locations for Surges yet:
            continue
        end
        p2 = get(grid, c, nothing)
        if p2 == nothing
            grid[c] = p
        else
            println(stdout, "\n[!] Test Failed: at $c have both $p and $p2.")
            @test false
        end
    end
    # distance between prerequisites
    d(a, b) = (a[1]-b[1])^2 + (a[2]-b[2])^2
    for project_type in keys(PROJECT_CHART_COORDINATES)
        p1g = PROJECT_CHART_COORDINATES[project_type]
        if isempty(p1g)
            continue
        end
        for p in prerequisites(project_type)
            expect = 2
            if project_type == AdvancedFurnace && p == Smelter
                expect = 5
            end
            p2g = PROJECT_CHART_COORDINATES[p]
            if isempty(p2g)
                continue
            end
            distance2 = d(p1g, p2g)
            if distance2 > expect
                println(stdout, "\n[!] Test Failed: distance between $project_type @$p1g and $p @$p2g == $distance2.")
                @test false
            end
        end
    end
end

@testset "Planet precursors" begin
    @test precursor(Iron) == AnyOf([
        find_planet("Drasta"),
        find_planet("Anadius"),
        find_planet("Dholen")
    ])
    @test precursor(Opalite) == AnyOf([
        find_planet("Typhon"),
        find_planet("Surtur"),
        find_planet("Vesta")
    ])
end

@testset "precursor" begin
    @test precursor(pl"Drasta") == nothing
    @test precursor(pl"Solveig") == Telescope2
    # @test precursor(Hammer(10)) == lookup_recipie(Hammer)
    @test precursor(Copper) ==
        AnyOf([
        pl"Balor",
        pl"Drasta",
            pl"Anadius"
        ])
    @test precursor(Iron(5)) == AnyOf([
        pl"Anadius",
        pl"Drasta",
        pl"Dholen"
    ])
    @test precursor(rx"Battery") == AllOf([CopperBar, CopperWire])
    @test precursor(AsteroidAutoMiner) == AllOf([
        AsteroidHarvester, SolarPanel, AdvancedComputer])
    @test precursor(AsteroidAutoMiner()) == AllOf([
        AsteroidHarvester, SolarPanel, AdvancedComputer])
end

@testset "spot-check delta calculations against real game data" begin
    # I wish I had started collecting data for this test much earlier.
    # I just have my current game state to work with.
    let
        game = GameState()
        add_modifier!(NoAdsMineBoost(), game)
        add_modifier!(Engineering(8), game)
        add_modifier!(Aeronautical(8), game)
        add_modifier!(Packaging(5), game)
        add_modifier!(Forge(10), game)
        add_modifier!(Workshop(10), game)
        add_modifier!(Astronomy(2), game)
        add_modifier!(Laboratory(4), game)
        add_modifier!(Terrarium(4), game)
        add_modifier!(Lounge(9), game)
        add_modifier!(BackupGenerator(2), game)
        add_modifier!(Underforge(4), game)
        add_modifier!(Dorm(3), game)
        for project in [
            AsteroidMiner, Smelter, Management, Telescope1, Beacon, Crafter,
            Rover, Telescope2, Telescope3, AdvancedMining,
            AsteroidRefinedDrilling, AdvancedCargoHandling, Telescope4,
            AdvancedThrusters, Telescope5, AdvancedFurnace, CargoLogistics,
            AdvancedCrafter, AsteroidHarvester, ResourceDetails,
            AdvancedItemValue, Colonization, ColonizationEfficiency,
            ColonizationScouting
            ]
            add_researched_project!(project, game)
        end
        delta(rx"SmeltingEfficiency", game.modifiers) == BronzeBar(-156)
    end
end

@testset "spot test development_level" begin
    @test development_level(nothing) == 0
    @test development_level(pl"Balor") == 1
    @test development_level(Copper) == 2
    @test development_level(Management) == 3
    @test development_level(Telescope1) == 6
    @test development_level(pl"Elysta") == development_level(Telescope8) + 1
    @test development_level(PreferredVendor) == 22
    @test development_level(SuperiorMining) == 18
end

