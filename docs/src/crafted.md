## Crafted Items

```@raw html
<!-- Thanks Google Gemeni. -->
<style>
  /* 1. Find the wrapper Documenter puts around tables and restrict its height */
  article.content table {
    display: block;
    max-height: 70vh; /* Limits table size to 70% of view height */
    overflow-y: auto; /* Adds the vertical scrollbar */
    border-collapse: collapse;
  }

  /* 2. Anchor Documenter's <th> elements to the top */
  article.content th {
    position: sticky;
    top: 0;
    z-index: 2;
    /* Match Documenter's standard background color so data doesn't bleed behind text */
    background-color: var(--documenter-bg, white); 
  }
</style>
```

```@setup crfted_table
using XML, IdlePlanetMinerTools, InteractiveUtils

html_str = replace(XML.write(html_table(sort(subtypes(Crafted); by = base_selling_price),
                                        CRAFTED_TABLE_COLUMNS)),
                   "\$" => r"\$")
```

```@example crfted_table
RawHTMLWrapper(html_str) # hide
```

