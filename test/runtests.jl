using IdlePlanetMinerTools
using Test

@testset "arithmetic" begin
    @test t"Iron" + 2 * t"Iron" == 3 * t"Iron"
end
