using IdlePlanetMinerTools
using Test

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
