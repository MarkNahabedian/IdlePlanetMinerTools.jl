# Generate reference tables

using XML

export html_table, RawHTMLWrapper

struct RawHTMLWrapper
    html::String
end

Base.show(io::IO, ::MIME"text/html", w::RawHTMLWrapper) = print(io, w.html)


### We will need to introduce some sort of State structure for each
### table if we want to indicate which planet is the first provider of
### a given ore.

column_name_pretty(name::Symbol) = column_name_pretty(Val(name))

column_name_pretty(::Val{S}) where S = string(S)


function html_table(row_things, columns)
    XML.h("table",
          XML.h("tr",
                map(columns) do cl
                    XML.h("th", column_name_pretty(cl))
                end...),
          map(row_things) do rt
              XML.h("tr",
                    map(columns) do cl
                        XML.h("td", table_cell_content(rt, Val(cl)))
                    end...;
                    id = xml_id(rt))
              end...)
end


############################################################
# Planets

# html_table(ALL_PLANETS, PLANET_TABLE_COLUMNS)

export PLANET_TABLE_COLUMNS

PLANET_TABLE_COLUMNS = (:Number, :Name, :Direction, :Telescope, :Cost, :Ores)

xml_id(p::Planet) = "planet$(p.name)"

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


############################################################
# Ores

# html_table(subtypes(Ore), ORE_TABLE_COLUMNS)

export ORE_TABLE_COLUMNS

ORE_TABLE_COLUMNS = (:Name, # :RecipieUnlock,
                     :Planets, :BasePrice,
                     # :ImmediaterItems, :IndirectItems
                     )

xml_id(o::Type{<:Ore}) = "ore_$(nameof(o))"

column_name_pretty(column::Val{:RecipieUnlock}) =
    XML.h("div",
          XML.h("div", "Recipie"),
          XML.h("div", "Unlock"))

column_name_pretty(column::Val{:BasePrice}) = "Base Price"

column_name_pretty(column::Val{:ImmediaterItems}) =
    XML.h("div",
          XML.h("div", "Immediate"),
          XML.h("div", "Products"))

column_name_pretty(column::Val{:IndirectItems}) =
    XML.h("div",
          XML.h("div", "Indirect"),
          XML.h("div", "Products"))


table_cell_content(x::Type{<:Thing}, column::Val{:Name}) =
    let
        name = string(nameof(x))
    end

# table_cell_content(x::Type{<:Ore}, column::Val{:RecipieUnlock})

table_cell_content(x::Type{<:Ore}, column::Val{:Planets}) =
    XML.h("div",
          map(ORE_PLANETS[x]) do planet
              XML.h("div", planet.name)
          end...)

# Probably should use the compact string representation
table_cell_content(x::Type{<:Ore}, column::Val{:BasePrice}) =
    "$(base_selling_price(x))"


# table_cell_content(x::Type{<:Ore}, column::Val{:ImmediaterItems})
# table_cell_content(x::Type{<:Ore}, column::Val{:IndirectItems})
    
                   
############################################################
# Alloys

# html_table(subtypes(Alloy), ALLOY_TABLE_COLUMNS)

export ALLOY_TABLE_COLUMNS

ALLOY_TABLE_COLUMNS = (:Name, :RecipieUnlock, :BasePrice,
                       :BaseProdictionTime, :Ingredients,
                       # :ImmediaterItems, :IndirectItems
                       )

xml_id(a::Type{<:Alloy}) = "alloy_$(nameof(a))"

column_name_pretty(column::Val{:BaseProdictionTime}) =
    XML.h("div",
          XML.h("div", "Base"),
          XML.h("div", "Production"),
          XML.h("div", "Time"))


table_cell_content(x::Type{<:Thing}, column::Val{:RecipieUnlock}) =
    "$(lookup_recipie(x).duration_seconds)"


# Probably should use the compact string representation
table_cell_content(x::Type{<:Thing}, column::Val{:BasePrice}) =
    "$(base_selling_price(x))"

table_cell_content(x::Type{<:Thing}, column::Val{:BaseProdictionTime}) =
    "$(lookup_recipie(x).duration_seconds)"

table_cell_content(x::Type{<:Thing}, column::Val{:Ingredients}) =
    let
        r = lookup_recipie(x)
        XML.h("div",
              map(r.ingredients) do ingredient
                  XML.h("div",
                        "$(nameof(typeof(ingredient))) $(ingredient.count)")
                  end...)
    end

# table_cell_content(x::Type{<:Ore}, column::Val{:ImmediaterItems})
# table_cell_content(x::Type{<:Ore}, column::Val{:IndirectItems})

############################################################
# Crafted Items

# html_table(subtypes(Crafted), CRAFTED_TABLE_COLUMNS)

export CRAFTED_TABLE_COLUMNS

CRAFTED_TABLE_COLUMNS = (:Name, :RecipieUnlock, :BasePrice,
                         :BaseProdictionTime, :Ingredients,
                         # :ImmediaterItems, :IndirectItems
                         )

xml_id(i::Type{<:Crafted}) = "crafted_(nameof(i))"


