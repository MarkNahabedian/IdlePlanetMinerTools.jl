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
    @test length(subtypes(Project)) == 125
    @test length(ALL_RECIPIES) ==  197
    @test length(subtypes(Room)) == 22
end

@testset "recipie ingredient modifiers" begin
    meths = cat(map(methods, [
        smelt_ingredient_scalar,
        craft_ingredient_scalar
    ])..., dims=1)
    specs = filter(t -> isconcretetype(t) && t <: Project,
                   Set(map(meths) do m
                           Base.unwrap_unionall(m.sig).parameters[2]
                       end))
    modifiers = map(s ->  s(), collect(specs))
    r = rx"PlatinumBar"
    @test delta(r, []) ==
        Platinum(-1000.0) + GoldBar(-2.0) + PlatinumBar(1)
    @test delta(r, modifiers) ==
        Platinum(-800.000) + GoldBar(-1.600) + PlatinumBar(1)
end

@testset "project prerequisites" begin
    @test prerequisites(rx"Asteroid Miner".make) == []
    @test prerequisites(rx"Rover".make) == [AsteroidMiner]
    @test Set(prerequisites(rx"superior mining".make)) ==
        Set([AdvancedThrusters, AdvancedCargoHandling])
end

@testset "room modifiers" begin
    @test isapprox(smelt_ingredient_scalar(Robotics(3)), 1)
    @test isapprox(smelt_ingredient_scalar(Underforge(3)), 0.82)
    @test isapprox(craft_ingredient_scalar(Engineering(2)), 1)
    @test isapprox(craft_ingredient_scalar(Dorm(4)), 0.78)
    @test isapprox(smelt_speed_scalar(Engineering(2)), 1)
    @test isapprox(smelt_speed_scalar(Forge(3)), 1.4)
    @test isapprox(craft_speed_scalar(Astronomy(2)), 1)
    @test isapprox(craft_speed_scalar(Workshop(4)), 1.5)
end

@testset "add_researched_project" begin
    have = Modifier[Management(), Telescope1()]
    l1 = length(have)
    add_researched_project(Telescope5, have)
    @test length(have) == l1 + 4
end

