## Crafted Items

```@setup crfted_table
using XML, IdlePlanetMinerTools, InteractiveUtils

html_str = replace(XML.write(html_table(sort(subtypes(Crafted); by = base_selling_price),
                                        CRAFTED_TABLE_COLUMNS)),
                   "\$" => r"\$")
```

```@example crfted_table
RawHTMLWrapper(html_str) # hide
```

