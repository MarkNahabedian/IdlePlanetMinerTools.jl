## Ores

```@setup ores_table
using XML, IdlePlanetMinerTools, InteractiveUtils

html_str = replace(XML.write(html_table(sort(subtypes(Ore); by = base_selling_price),
                                        ORE_TABLE_COLUMNS)),
                   "\$" => r"\$")
```

```@example ores_table
RawHTMLWrapper(html_str) # hide
```

