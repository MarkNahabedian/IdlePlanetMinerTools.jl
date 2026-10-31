## Planets

```@setup planet_table
using XML, IdlePlanetMinerTools

html_str = replace(XML.write(html_table(ALL_PLANETS, PLANET_TABLE_COLUMNS)),
                   "\$" => r"\$")
```

```@example planet_table
RawHTMLWrapper(html_str) # hide
```

