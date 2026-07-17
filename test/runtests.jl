using IdlePlanetMinerTools
using Test

@testset "arithmetic" begin
    @test t"Iron" + 2 * t"Iron" == 3 * t"Iron"
    @test t"Silver" + t"Gold" == Thing[t"Silver", t"Gold"]
end
