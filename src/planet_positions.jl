export PLANET_POSITIONS, MOTHERSHIP_LOCATION, planet_direction

#=

planets = open("planets.json", "r") do io
    JSON.parse(read(io, String))
end

planets_data = planets["interactiveMaps"] ["interactive-map-6ab11b5775492"] ["markers"]

planet_positions = OrderedDict()
for pd in planets_data
    planet_positions[pd["popup"]["title"]] = pd["position"]
end

println(planet_positions)

=#

PLANET_POSITIONS = OrderedDict(
    "Balor" => Float64[446.97987405754634, 707.813887967734],
    "Drasta" => Float64[506.28845532956797, 725.3147808021012],
    "Anadius" => Float64[521.4028627774304, 592.8206476772717],
    "Dholen" => Float64[414.7181271659101, 577.5294635341127],
    "Verr" => Float64[583.8934245647915, 745.1137706753244],
    "Newton" => Float64[499.3941642129991, 813.3495750598263],
    "Widow" => Float64[449.54313613934755, 825.7239437305908],
    "Acheron" => Float64[390.1461665196776, 822.0116331293615],
    "Yangtze" => Float64[302.28814895724906, 656.5486463317094],
    "Solveig" => Float64[562.1498910433052, 446.18437892871145],
    "Imir" => Float64[643.4671708797582, 504.16713498600825],
    "Relic" => Float64[481.8932713786321, 421.4356415871823],
    "Nith" => Float64[420.72853480599576, 395.6262440738733],
    "Batalla" => Float64[543.4115613418618, 381.8376618407356],
    "Micah" => Float64[707.813887967734, 667.8623548306941],
    "Pranas" => Float64[733.2697320904497, 613.7686860699232],
    "Castellus" => Float64[221.67797590198262, 618.3648801476357],
    "Gorgon" => Float64[197.63634534164, 740.3407999023152],
    "Parnitha" => Float64[558.6143571373725, 897.3185053257287],
    "Orisoni" => Float64[634.274782724333, 903.3289129658143],
    "Theseus" => Float64[275.7716446627535, 918.5317087613253],
    "Zelene" => Float64[237.23432508808668, 459.97296116184907],
    "Han" => Float64[288.4995667241114, 305.8236828631818],
    "Strennus" => Float64[696.8537328593425, 295.57063453597686],
    "Osun" => Float64[770.3928381027436, 834.386001800126],
    "Ploitari" => Float64[759.0791296037587, 903.3289129658144],
    "Elysta" => Float64[535.6333867488097, 989.5959402705732],
    "Tikkun" => Float64[487.90367901871775, 1006.212949628457],
    "Satent" => Float64[417.90010768124955, 1006.5665030190503],
    "Urla Rast" => Float64[236.17366491630685, 867.973573906487],
    "Vular" => Float64[193.04015126392744, 940.8055723687014],
    "Nibiru" => Float64[804.3339635996978, 738.2194795587556],
    "Xena" => Float64[827.6684873788538, 787.0098474606273],
    "Rupert" => Float64[851.0030111580099, 689.7826650474772],
    "Pax" => Float64[815.6660889654819, 419.04372260139564],
    "Ivyra" => Float64[604.342712474619, 265.5046173579947],
    "Utritis" => Float64[161.22034611053283, 440.5275246792191],
    "Dosie" => Float64[125.51145366061218, 496.3889603929563],
    "Zulu" => Float64[114.5512985522207, 691.1968786098503],
    "Unicae" => Float64[330.57242020471097, 1048.2858031090568],
    "Dune" => Float64[389.2622830431944, 248.1944801964782],
    "Naraka" => Float64[456.0838738653231, 230.87036405740776],
    "Daedalus" => Float64[545.8864350760145, 214.96046148071045],
    "Clovis" => Float64[875.0446417183525, 602.1014241803451],
    "Zero" => Float64[898.3791654975086, 743.876333808248],
    "Sotomi" => Float64[896.9649519351353, 493.9140866588034],
    "Remidian" => Float64[702.8641404994282, 1079.0449480906714],
    "Muse" => Float64[771.09994488393, 1053.9426573585492],
    "Arabis" => Float64[815.2941187080893, 998.0812216448118],
    "Vesna" => Float64[109.60155108391486, 903.6824663564078],
    "Chandra" => Float64[84.49926035179243, 846.7603704708906],
    "Vega" => Float64[242.89117933757905, 1063.8421522951608],
    "Crius" => Float64[65.05382386916236, 561.4427842621187],
    "Singhana" => Float64[42.77996026178612, 608.4653852110241],
    "Zumbia" => Float64[31.819805153394636, 750.5938482295202],
    "Elysium" => Float64[164.75588001646554, 282.1356056934324],
    "Nyota" => Float64[96.873629022557, 316.07673119038674],
    "Doral" => Float64[254.5584412271571, 168.99852070358486],
    "Nikara" => Float64[742.4621202458749, 197.28279195104673],
    "Limbo" => Float64[825.9007204258876, 275.41809127216027],
    "Bob" => Float64[892.3687578574229, 285.3175862087719],
    "Midas" => Float64[960.2051942088829, 376.7447327281724],
    "Antigone" => Float64[988.9331162702406, 444.4284989122459],
    "Hecate" => Float64[1020.5752518939715, 522.3696244092002],
    "Sterop" => Float64[898.6782822743015, 873.0752518939717],
    "Lavinia" => Float64[901.0067093990478, 942.6021638285528],
    "Ren" => Float64[970.6194077712559, 845.7615433949868],
    "Gorgons" => Float64[613.0615792887368, 1091.7728701520296],
    "Pontus" => Float64[671.0443353460336, 1118.6429278371181],
    "Leto" => Float64[542.3509011700819, 1153.9982668964456],
    "Laconia" => Float64[88.38834764831843, 1013.2840174403225],
    "Awohali" => Float64[139.30003589374985, 1127.8353159925432],
    "Pegasi" => Float64[255.26554800834364, 1228.244478921033],
    "Typhon" => Float64[381.8376618407356, 83.4386001800126],
    "Surtur" => Float64[497.80317395532944, 48.08326112068523],
    "Vesta" => Float64[599.6265504461923, 98.99494936611664]
)

PLANET_POSITIONS_CENTER = sum(values(PLANET_POSITIONS)) / length(PLANET_POSITIONS)

MOTHERSHIP_LOCATION = [ PLANET_POSITIONS["Relic"][1],
                        PLANET_POSITIONS["Micah"][2], ]

#=
for (k, v) in PLANET_POSITIONS
    println(k, "\t", v - PLANET_POSITIONS_CENTER)
end

# The first coordinate is horizontal position, the second is vertical,
but PLANET_POSITIONS_CENTER is not the location of the mother ship.

Maybe make a plot with the innermost and outermost planets, guess a
location for the mother ship and compare the plot with the map in the
game.

```
using Plots
let
    sample_planets = [PLANET_POSITIONS["Balor"],
                      PLANET_POSITIONS["Drasta"],
                      PLANET_POSITIONS["Newton"],
                      PLANET_POSITIONS["Dholen"],
                      PLANET_POSITIONS["Anadius"],
                      PLANET_POSITIONS["Micah"],
                      PLANET_POSITIONS["Relic"]
                      ]
    scatter(map(p -> p[1], values(sample_planets)),
            map(p -> p[2], values(sample_planets)),
            markersize=5, markershape=:circle, markercolor="red")
    scatter!([MOTHERSHIP_LOCATION[1]],
             [MOTHERSHIP_LOCATION[2]],
             markersize=5, markershape=:square, markercolor="yellow")
end
```

The above looks good.

=#


"""
    planet_direction(planet::Planet)

Returns the compass direction of the planet in degrees, with 0
directly upwards and 90 to the right.
"""
function planet_direction(planet::Planet)
    x, y = PLANET_POSITIONS[planet.name] - MOTHERSHIP_LOCATION
    round(90 - rad2deg(atan(y, x)))
end


