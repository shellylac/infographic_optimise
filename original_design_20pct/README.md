# Original design, reduced footprint

This folder contains only the source files needed to reproduce the revised
valueboxes:

- `info_valuebox.R`: component functions, using the original authoring API.
- `info_valuebox.css`: reduced-width, tighter-spaced original card design.
- `example_statements_short.csv`: shortened statements with originals for reference.
- `info_valuebox_example.qmd`: runnable Quarto example covering all nine statements.

The example reads the existing `../valuebox_config.csv` directly. Keep this
folder within the project, or adjust that path when moving the files. No original
project files or input data were changed.

## Reproduce

Use the R dependencies listed in the project's root README and an installed
Quarto. With this folder as the working directory, render:

```text
quarto render info_valuebox_example.qmd
```

Alternatively, open the QMD in RStudio and select Render. This generates the
HTML preview; generated files are deliberately not retained in this source folder.
Quarto's R launcher failed in the creation environment, although the actual
component output was built and checked through R separately.

## Integrate

Use this folder's R and CSS files together. Source one version of the functions
per R session, and add the CSS after the site's stylesheet. Keep the site's
existing theme and font provisioning. Adjust paths to your execution directory.

```r
source("info_valuebox.R")
config <- read_value_box_config("../valuebox_config.csv")
statements <- readr::read_csv("example_statements_short.csv")
```

The section is capped at 44rem (704px at a 16px root size), with tighter padding
and gaps. Statistics are 32px rather than 34px and icons 30px rather than 36px.
Heading, context and statement font sizes remain unchanged. Cards stack below
38rem available width, with no fixed heights or clipped descriptions.

To customise the maximum width:

```css
.slim-value-box-region { --slim-value-box-max-width: 44rem; }
```

The card structure, configured icons and colours, accent stripe, comparison
emphasis and statement divider are retained. This remains a custom component
using the original QLD font stack and colour variables.

During validation, the main four-card example used 19.3% less area and 14.7% less
height in the desktop comparison. Other examples saved roughly 10–14% area.
Savings vary with content, available width and font. Desktop and phone previews
were visually reviewed and component checks passed. Generated previews,
comparison files, screenshots and validation tools have been removed to keep
only the reproduction sources.
