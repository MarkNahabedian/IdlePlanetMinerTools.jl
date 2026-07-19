using IdlePlanetMinerTools
using Test

@testset "arithmetic" begin
    @test t"Iron" + 2 * t"Iron" == 3 * t"Iron"
    @test t"Silver" + t"Gold" == Thing[t"Silver", t"Gold"]
    @test -(Aluminum(2) - Platinum(1)) == Thing[Aluminum(-2), Platinum(1)]
    @test (2 * t"Iron" + t"Silicon") + (Silicon(4) + Copper(2)) ==
        Thing[Copper(2), Iron(2), Silicon(5)]
    @test t"Gold Bar" - 3 * t"Lead Bar" ==
        sort(Thing[LeadBar(-3), GoldBar(1)]; by = ordinal)
end
