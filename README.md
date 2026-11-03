# PHD key-fact value boxes

Use these components at the top of an HTML Quarto subpage, before the narrative
and dashboards. They wrap `bslib::value_box()` and `bslib::layout_column_wrap()`;
no Shiny server is needed. Icons are inline SVGs from `bsicons` (Bootstrap)
or `fontawesome`, selected per config row. Rendering does not download icons
or load an external icon font.

## Setup

Install the packages once in R:

```r
install.packages(c("bslib", "bsicons", "fontawesome", "htmltools", "readr", "dplyr", "purrr"))
```

Install Quarto and its usual R rendering packages (`knitr`, `rmarkdown`) if they
are not already available. In RStudio, open `info_valuebox_example.qmd` and select
**Render**, or run:

```sh
quarto render info_valuebox_example.qmd
```

The generated `info_valuebox_example.html` is a self-contained preview.

## Smallest page example

Keep `info_valuebox.R`, `info_valuebox.css` and `valuebox_config.csv` together
with the page, or adjust their paths relative to the page's execution directory.
For nested website pages, use your project's established execution-directory
convention consistently for `source()` and the config path.

````qmd
---
title: "Smoking"
format:
  html:
    css: info_valuebox.css
execute:
  echo: false
  message: false
---

```{r}
source("info_valuebox.R")
config <- read_value_box_config("valuebox_config.csv")

info_value_box_layout(
  info_value_box(
    title = "Smoking rates",
    value = "53.4%",
    type = "trend",
    demographic_var = "male",
    direction = "decrease",
    context = "In adult males",
    description = paste(
      "The proportion of Queensland adult males who smoked daily",
      "decreased by 53.4% from 2002 to 2024."
    ),
    config = config
  )
)
```

## Main page content
````

Use an ordinary Bootstrap 5 Quarto HTML theme (the example uses `cosmo`).
Keep the site's existing theme; add this CSS to its existing CSS list, after
the site's main stylesheet. In a bslib page, include the CSS with
`htmltools::includeCSS("info_valuebox.css")` once. The components are HTML-only.

## What authors supply

| Argument | Purpose |
| --- | --- |
| `title` | Short topic heading. |
| `value` | Formatted display text, e.g. `"25.5%"`, `"2.0\u00d7"`, `"1 in 10"`. |
| `value_note` | Optional wording beside the statistic, e.g. `"higher"` or `"the proportion"`. |
| `type` | `"comparative"`, `"trend"`, or `"domain_statistic"`. |
| `demographic_var` | Exact key from the config, e.g. `"sex"`, `"persons"`, `"smoking"`. |
| `context` | Highlighted population/comparison line. For comparisons use `"Males vs females"`; the first group is automatically larger and bolder. |
| `description` | Full explanatory statement, normally including the reporting period. |
| `direction` | Required for trends: `"increase"` or `"decrease"`. |
| `config` | Result of `read_value_box_config()`, read once per page. |

For trends, `value_note` defaults to "increase" or "decrease".
Supply it explicitly to use "higher" or "lower" instead. The arrow follows
`direction`, not the sign of the display text. Colours identify categories,
not whether a change is good or bad. All display fields are plain text and
are HTML-escaped automatically; Markdown and HTML markup are not interpreted.

The functions format presentation only. Authors remain responsible for the
statistical wording, rounding, percentages versus percentage points, and
consistent values across the statistic and description. The example's 2.0×
comparison describes a **proportion**, rather than a mortality/incidence rate.
The supplied CSV's `type_id` links to config row `id`; authors still choose the
display fields explicitly. No attempt is made to extract statistics from prose.

## Layout

`info_value_box_layout(box1, box2, ...)` also accepts one ordinary list of boxes.
Use `purrr::pmap(info_value_box, config = config)` for a table with columns named
after the arguments; the Quarto example demonstrates this.

| Number of boxes | Wide container |
| --- | --- |
| 1 | One full-width card |
| 2 | One row of two |
| 3 | One row of three |
| 4 | Two rows of two |
| More than 4 | Two columns |

Cards stack when the containing region is at most 44rem wide (about 704px at
the usual root font size), or the viewport is that narrow. This supports
sidebars as well as phones. Heights follow content, with equal heights within
each row; there are no fixed heights to clip longer text.

The entire valuebox section is capped at 48rem (about 768px at the usual root
font size), and never exceeds its parent text column. The example uses the
equivalent 768px limit for the page body. On your website, place the section inside
the normal text column rather than a full-width Quarto column.

To match your website's exact reading-width limit, set this variable in the
site stylesheet, loaded after `info_valuebox.css`:

```css
.info-value-box-region {
  --info-value-box-max-width: 70ch;
}
```

`ch` measures the width of a zero in the current font, so it approximates a
character limit rather than counting actual characters. You can also use the
site's existing CSS width variable here. The section stays aligned with the
start of the text column and shrinks automatically on smaller devices. Widths
at or below the stacking threshold above display one card per row.

## Editing the config

`valuebox_config.csv` is the working config derived from the supplied template.
Each type/demographic pair must be unique. To add a category, add a row with a
six-digit hex `highlight_colour`, an `icon_library` of `bootstrap` or
`fontawesome`, and a valid `icon` name from that library. For trend
rows, `icon` is the increase icon; also set `icon_decrease`.
The reader checks these fields and icon availability, and fails with an error
for invalid configuration. Unknown category pairs also fail explicitly.

For example, these rows mix libraries:

```csv
type,demographic_var,highlight_colour,icon_library,icon,icon_decrease
comparative,sex,#91358C,fontawesome,mars-and-venus,
domain_statistic,general,#16445B,bootstrap,pie-chart,
trend,persons,#008540,fontawesome,arrow-trend-up,arrow-trend-down
```

The library applies to both icons in a trend row. Changing providers requires
changing the icon names to match that provider; the valuebox calls do not change.
If you have your own older working config, add the `icon_library` column and
set it to `bootstrap` for rows containing the previous Bootstrap names.
Only the selected provider's R package is required to render its rows.

The original files under `input/` are unchanged. Changes in the working config:

- `highligh_colour` is corrected to `highlight_colour`, with explicit hex values
  replacing colour labels. Hues follow the mockups with darker text colours.
- `comparison` becomes `comparative`; `domain_stat` becomes `domain_statistic`.
  Both original type names remain accepted in `info_value_box()` calls.
- `hospitalistion` becomes `hospitalisation`; `weigh` becomes `weight`.
- The names in the original `flaticon_icon_name` column are Font Awesome names.
  The working config restores all of these names and sets `icon_library` to
  `fontawesome`, including `smoking`, `stethoscope` and `weight-scale`.
  Trend names are separated into the increase and decrease columns.
- Row IDs are preserved, including the example adult hospitalisation trend
  linked to `persons` (id 5). Choose `adult` (id 8) if your team prefers the
  age-specific colour for that fact.

Browse names at [Bootstrap Icons](https://icons.getbootstrap.com/) or the
[Font Awesome R icon reference](https://rstudio.github.io/fontawesome/articles/icon-reference.html).
For Font Awesome, use names bundled with the installed R package; paid Pro
icons or newer names found on the main website may not be included. Available
names can be listed in R with `fontawesome::fa_metadata()$icon_names`.
Icons decorate text that already communicates the meaning; they are hidden
from screen readers. Text and direction words communicate meaning without colour.

## Styling and maintenance

Cards use compact padding (0.5rem vertically), 0.25rem internal gaps and 0.5rem
between cards to keep the summary section short, with prominent 2.125rem
statistics, bold 1rem headings and 2.25rem icons. Statements use smaller
0.75rem text with a 1.4 line
height. Comparative context lines use
the pattern `"Focal group vs reference group"` (also accepting `VS` or `vs.`).
The focal group is 1rem and bold; the remaining comparison is 0.9375rem
and medium weight. Other context text is displayed as supplied.

All styling is in `info_valuebox.css` and scoped to these components. It uses
the [Queensland design system typography](https://www.design-system.health.qld.gov.au/styles/typography)
font stack and [colour variables](https://www.design-system.health.qld.gov.au/styles/colour)
for text, borders and headings when the website supplies them. Standalone
fallbacks use white, dark neutral text and system fonts. Noto Sans is used if
the host site supplies it; this component does not download fonts.

The left stripe, rounded corners and category palette are adaptations of the
mockups, rather than an official Queensland design system component. Category
colours are kept in the CSV, separate from general site styling. If colours
change, check text contrast against the white card background (at least 4.5:1
for the context text). The supplied defaults meet that threshold.

This replaces the earlier function interface. Original scripts are preserved
in `original/`; old calls using `condition`, numeric `value`, `group`, `reference`
or `info_value_box_styles()` must be updated to the new explicit display fields
and CSS inclusion. No global `library()` calls or remote icon cache are used.

Run `Rscript tests/check_valueboxes.R` for the config, selection, escaping and
layout checks. Render the Quarto example after changing CSS or upgrading bslib,
and inspect the wide and narrow layouts in a browser.

Validated with R 4.6.1, bslib 0.12.0, bsicons 0.1.2 and fontawesome 0.5.3. The Quarto example
renders successfully and the R checks pass. Automated visual inspection was
blocked because the available browser tool does not allow local file URLs;
the generated HTML is provided for local visual review.
