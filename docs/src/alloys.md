## Alloys

```@setup alloys_table
using XML, IdlePlanetMinerTools, InteractiveUtils

html_str = replace(XML.write(html_table(sort(subtypes(Alloy); by = base_selling_price),
                                        ALLOY_TABLE_COLUMNS)),
                   "\$" => r"\$")
```

```@example alloys_table
RawHTMLWrapper(html_str) # hide
```

