## Planets

```@setup planet_table
using XML, IdlePlanetMinerTools

struct RawHTMLWrapper
    html::String
end

Base.show(io::IO, ::MIME"text/html", w::RawHTMLWrapper) = print(io, w.html)

html_str = replace(XML.write(html_table(ALL_PLANETS, PLANET_TABLE_COLUMNS)), "\$" => r"\$")
```

```@example planet_table
RawHTMLWrapper(html_str) # hide
```

