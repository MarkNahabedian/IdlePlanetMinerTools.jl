# Generate reference tables

using XML

export html_table, RawHTMLWrapper, think_profitability_rows

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

xml_id(p::Planet) = "planet_$(p.name)"

table_cell_content(planet::Planet, column::Val{:Number}) = "$(planet.number)"
table_cell_content(planet::Planet, column::Val{:Name}) = planet.name
table_cell_content(planet::Planet, column::Val{:Direction}) =
    "$(planet_direction(planet))° $(planet_direction_arrow(planet))"
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
                     # :UsedIn
                     )

table_href_for_item(x::Type{<:Ore}) = "../ores/index.html#" * xml_id(x)

xml_id(t::Thing) = xml_id(typeof(t))
xml_id(o::Type{<:Ore}) = "ore_$(nameof(o))"

column_name_pretty(column::Val{:RecipieUnlock}) =
    XML.h("div",
          XML.h("div", "Recipie"),
          XML.h("div", "Unlock"))

column_name_pretty(column::Val{:BasePrice}) = "Base Price"

column_name_pretty(column::Val{:UsedIn}) = "Used In"

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
              XML.h("div",
                    XML.h("a", planet.name;
                          href = "../planets/index.html#$(xml_id(planet))"))
          end...)

# Probably should use the compact string representation
table_cell_content(x::Type{<:Ore}, column::Val{:BasePrice}) =
    "$(unparse_selling_price(base_selling_price(x)))"


# table_cell_content(x::Type{<:Thing}, column::Val{:UsedIn})
#=
begin
    map(println, crafting_plan(rx"NuclearCapsule".ingredients)[1])
    nothing
end
=#
    
                   
############################################################
# Alloys

# html_table(subtypes(Alloy), ALLOY_TABLE_COLUMNS)

export ALLOY_TABLE_COLUMNS

ALLOY_TABLE_COLUMNS = (:Name, :RecipieUnlock, :BasePrice,
                       :BaseProdictionTime, :Ingredients,
                       # :UsedIn
                       )

table_href_for_item(x::Type{<:Alloy}) = "../alloys/index.html#" * xml_id(x)

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
    "$(unparse_selling_price(base_selling_price(x)))"

table_cell_content(x::Type{<:Thing}, column::Val{:BaseProdictionTime}) =
    "$(lookup_recipie(x).duration_seconds)"

table_cell_content(x::Type{<:Thing}, column::Val{:Ingredients}) =
    let
        r = lookup_recipie(x)
        XML.h("div",
              map(r.ingredients.items) do item
                  XML.h("div",
                        XML.h("a", "$(nameof(typeof(item))) $(item.count)";
                              href = "$(table_href_for_item(x))"))
                  end...)
    end

# table_cell_content(x::Type{<:Ore}, column::Val{:UsedeIn})

############################################################
# Crafted Items

# html_table(subtypes(Crafted), CRAFTED_TABLE_COLUMNS)

export CRAFTED_TABLE_COLUMNS

CRAFTED_TABLE_COLUMNS = (:Name, :RecipieUnlock, :BasePrice,
                         :BaseProdictionTime, :Ingredients,
                         # :UsedIn
                         )

table_href_for_item(x::Type{<:Crafted}) = "../crafted/index.html#" * xml_id(x)

xml_id(i::Type{<:Crafted}) = "crafted_$(nameof(i))"


############################################################
# Optimal thing profitabolity

export THING_PROFITABILITY_COLUMNS

THING_PROFITABILITY_COLUMNS = (:name, :development_level, :sell_price,
                               :total_ore_cost, :smelting_time,
                               :crafting_time, :appreciation_per_time)

# html_table(identify_revenue_items(), THING_PROFITABILITY_COLUMNS)

table_cell_content(x::ThingConsolidatedCosts, column::Val{:name}) =
    let
        id 
        XML.h("a", x.name;
              href = "../crafted/index.html#$id"
              )
    end

column_name_pretty(column::Val{:development_level}) =
    XML.h("div",
          XML.h("div", "development"),
          XML.h("div", "level"))

column_name_pretty(column::Val{:sell_price}) =
    XML.h("div",
          XML.h("div", "sell"),
          XML.h("div", "price"))

column_name_pretty(column::Val{:total_ore_cost}) =
    XML.h("div",
          XML.h("div", "total"),
          XML.h("div", "ore"),
          XML.h("div", "cost"))

column_name_pretty(column::Val{:smelting_time}) =
    XML.h("div",
          XML.h("div", "total"),
          XML.h("div", "smelting"),
          XML.h("div", "time"))

column_name_pretty(column::Val{:crafting_time}) =
    XML.h("div",
          XML.h("div", "total"),
          XML.h("div", "crafting"),
          XML.h("div", "time"))

column_name_pretty(column::Val{:appreciation_per_time}) =
    XML.h("div",
          XML.h("div", "appreciation"),
          XML.h("div", "per"),
          XML.h("div", "time"))

xml_id(x::RevenueThing) = "revenue_thing_$(x.name)"

table_href_for_item(x::RevenueThing) = "../revenue_items/index.html#" * xml_id(x)

table_cell_content(x::RevenueThing, column::Val{:name}) =
    XML.h("a", x.name;
          href = table_href_for_item(x))

table_cell_content(x::RevenueThing, column::Val{:development_level}) =
    "$(x.development_level)"
table_cell_content(x::RevenueThing, column::Val{:sell_price}) =
    "$(unparse_selling_price(x.sell_price))"
table_cell_content(x::RevenueThing, column::Val{:total_ore_cost}) =
    "$(unparse_selling_price(x.total_ore_cost))"
table_cell_content(x::RevenueThing, column::Val{:smelting_time}) =
    "$(unparse_selling_price(x.smelting_time))"
table_cell_content(x::RevenueThing, column::Val{:crafting_time}) =
    "$(unparse_selling_price(x.crafting_time))"
table_cell_content(x::RevenueThing, column::Val{:appreciation_per_time}) =
    "$(round(x.appreciation_per_time, digits=3))"

