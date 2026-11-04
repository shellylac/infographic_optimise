# Reduce the footprint of the original valueboxes

This guide describes edits to the **main project-root `info_valuebox.css`**,
using its original `.info-value-box` selectors. It does not require switching
to the separate `.slim-value-box` implementation in this folder. No changes
have been applied to the main stylesheet by creating this guide.

Line numbers refer to the main stylesheet as inspected when this guide was
written. Find the selector and property if subsequent edits move the lines.

## 1. Change these CSS values

| Original line | Selector or rule | Property | Current value | New value | Purpose |
| --- | --- | --- | --- | --- | --- |
| 8 | `.info-value-box-region` | `max-inline-size` | `var(--info-value-box-max-width, 48rem)` | `var(--info-value-box-max-width, 44rem)` | Cap the section at 704px instead of 768px. |
| 10 | `.info-value-box-region` | `margin-block` | `0.5rem 0.75rem` | `0.375rem 0.5rem` | Reduce space above and below the section. |
| 33 | `.info-value-box > .card-body` | `padding` | `0.5rem 0.75rem` | `0.375rem 0.625rem` | Reduce vertical padding from 8px to 6px and horizontal padding from 12px to 10px. |
| 42 | `.info-value-box .value-box-area` | `gap` | `0.25rem` | `0.125rem` | Reduce gaps between the stacked card elements from 4px to 2px. |
| 64 | `.info-value-box-icon` | `font-size` | `2.25rem` | `1.875rem` | Reduce decorative icons from 36px to 30px. |
| 71 | `.info-value-box .value-box-value` | `font-size` | `2.125rem` | `2rem` | Reduce the statistic from 34px to 32px. |
| 96 | `.info-value-box .info-value-box-description` | `padding-top` | `0.25rem` | `0.1875rem` | Reduce spacing below the statement divider from 4px to 3px. |
| 107 | `@container (max-width: 44rem)` | Query threshold | `44rem` | `38rem` | Retain multiple columns inside the new 44rem maximum width. |
| 112 | `@media (max-width: 44rem)` | Query threshold | `44rem` | `38rem` | Apply the same threshold to the viewport fallback. |

Pixel equivalents assume a 16px root font. Keep `rem` units in the stylesheet.

**Change both stacking thresholds when reducing the maximum width.** Leaving
the original container query at 44rem would stack all the cards when their
section is capped at 44rem, potentially increasing the section's height.
Leave the declarations inside the two query blocks unchanged.

If another site stylesheet already sets `--info-value-box-max-width`, that value
takes precedence over the fallback on line 8. Update that override to `44rem`
as well, or remove it to use the new fallback. A narrower parent text column
still limits the section's actual width.

The statistic's accompanying note uses `0.65em` at line 79. Keep this value;
it will scale slightly with the statistic, from about 22.1px to 20.8px.

## 2. Reduce the gap between cards

The original R function sets this gap in the generated layout. Choose **one**
of these methods.

### Method A: make all presentation edits in CSS

Add this rule to the main stylesheet:

```css
/* Override the gap supplied inline by bslib's layout function. */
.info-value-box-grid {
  gap: 0.375rem !important;
}
```

This reduces the gap from 8px to 6px. The `!important` is intentional because
the original R layout supplies its gap inline. No R change is needed with
this method.

### Method B: change the R layout instead

In the main `info_valuebox.R`, line 163, inside `info_value_box_layout()`, change:

```r
fill = FALSE, gap = "0.5rem", class = "info-value-box-grid"
```

to:

```r
fill = FALSE, gap = "0.375rem", class = "info-value-box-grid"
```

With this method, no extra gap override is needed in CSS. Re-render the page
so the generated layout uses the updated R value.

## 3. Use shorter statements for the full effect

CSS cannot shorten statements. The measured reduction also used the edited
statements in `example_statements_short.csv` in this folder. That file retains
the original wording in a separate column for review.

To use those statements from the **project-root example QMD**, change its
`readr::read_csv()` path from:

```r
"input/example_statements.csv"
```

to:

```r
"original_design_20pct/example_statements_short.csv"
```

Keep selecting `statements$example_statement` as before; the column name and
row order are preserved. Continue reading the existing `valuebox_config.csv`
unchanged. For descriptions written directly in page code, edit that wording
there instead. Retain the figures, dates, population, comparison group and
qualifiers such as “standardised” and “daily”.

## 4. Preserve the existing design and text readability

Keep the original heading, context and statement font sizes, line heights,
colour variables, borders, accent stripe, corner radius and icon-selection
logic. The title-row gap at line 52 stays at `0.375rem`; it is different from
the internal vertical gap at line 42.

Keep content-driven heights, text wrapping and narrow-screen stacking. Avoid
fixed card heights, hidden overflow, line clamping or scaling the whole section:
these can hide content or make text harder to read.

Retain all original `.info-value-box` class names when editing the main files.
The `.slim-value-box` names in this folder exist only to let the separate
implementation coexist with the original in a comparison.

## 5. Re-render and check the result

Render the main `info_valuebox_example.qmd` again. Simply refreshing previously
rendered HTML may not reflect changes, especially when resources are embedded.
Check the four-, three- and two-card examples on a wide screen and a phone-sized
screen, including the longest title and comparison context. Confirm that text
wraps without clipping or horizontal scrolling and the intended columns remain.

The separate version built with these spacing values, the smaller card gap
and the shortened statements measured **19.3% less area** for the main four-card
example in the desktop comparison. Its height decreased **14.7%**. Other
examples saved roughly 10–14% area, and phone results differed. These are
content- and layout-dependent measurements, not a guaranteed 20% reduction
for every page or a measurement of CSS changes alone.
