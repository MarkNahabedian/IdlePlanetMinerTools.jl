## Best Revenue Items

All calculations used too make this table assume no modifiers on
material costs or processing times.

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

/* Apply an offset to the element targeted by the active link hash */
.table-container tr:target,
article.content tr:target {
  scroll-margin-top: 4lh; /* Adjust this value to match the exact height of your header row */
}
</style>
```

```@setup revenue_items
using XML, IdlePlanetMinerTools

html_str = replace(XML.write(html_table(identify_revenue_items(; game = GameState()),
                                        THING_PROFITABILITY_COLUMNS)),
                   "\$" => r"\$")
```

```@example revenue_items
RawHTMLWrapper(html_str) # hide
```

