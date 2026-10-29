# Generate reference tables

using XML

export html_table

function html_table(row_thiings, columns)
    XML.h("table",
          XML.h("tr",
                map(columns) do cl
                    XML.h("th", String(cl))
                end...),
          map(row_thiings) do rt
              XML.h("tr",
                    map(columns) do cl
                        XML.h("td", table_cell_content(rt, Val(cl)))
                    end...)
              end...)
end


############################################################
# Planets

# html_table(ALL_PLANETS, PLANET_TABLE_COLUMNS)

export PLANET_TABLE_COLUMNS

PLANET_TABLE_COLUMNS = (:Number, :Name, :Direction, :Telescope, :Cost, :Ores)

table_cell_content(planet::Planet, column::Val{:Number}) = "$(planet.number)"
table_cell_content(planet::Planet, column::Val{:Name}) = planet.name
table_cell_content(planet::Planet, column::Val{:Direction}) =
    "$(planet_direction(planet)) $(planet_direction_arrow(planet))"
table_cell_content(planet::Planet, column::Val{:Telescope}) = "$(planet.telescope_number)"
table_cell_content(planet::Planet, column::Val{:Cost}) = planet.price_string
table_cell_content(planet::Planet, column::Val{:Ores}) =
    XML.h("div",
          map(planet.ores) do ore_yield
              XML.h("div",
                    "$(ore_yield.ore) $(ore_yield.yield)")
          end...
          )

