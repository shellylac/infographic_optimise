library(tidyverse)
library(rmarkdown)

# Compact HTML key-fact cards. Include info_value_box_styles() once per page.
health_conditions <- c(
  "Coronary heart disease" = "cardiology",
  "COPD" = "pulmonology",
  "Dementia" = "neurology",
  "Diabetes" = "water_drop",
  "Stroke" = "bolt",
  "Lifestyle related" = "directions_run",
  "All cause mortality" = "stethoscope"
)
.material_symbol_cache <- new.env(parent = emptyenv())

material_symbol <- function(icon_name, icon_size = "36px") {
  if (!exists(icon_name, .material_symbol_cache, inherits = FALSE)) {
    url <- paste0(
      "https://fonts.gstatic.com/s/i/short-term/release/materialsymbolsrounded/",
      icon_name,
      "/default/48px.svg"
    )
    svg <- tryCatch(
      paste(readLines(url, warn = FALSE), collapse = ""),
      error = function(e) ""
    )
    if (!nzchar(svg)) {
      stop("Unable to load Material Symbol: ", icon_name)
    }
    assign(icon_name, svg, .material_symbol_cache)
  }
  svg <- get(icon_name, .material_symbol_cache, inherits = FALSE)
  svg <- gsub(' (width|height|fill)="[^"]*"', "", svg)
  size <- htmltools::htmlEscape(icon_size, attribute = TRUE)
  svg <- sub(
    "<svg",
    paste0(
      '<svg aria-hidden="true" focusable="false" class="info-value-box-icon" style="width:',
      size,
      ';height:',
      size,
      ';fill:currentColor"'
    ),
    svg,
    fixed = TRUE
  )
  htmltools::HTML(svg)
}

info_value_box_styles <- function() {
  htmltools::tags$style(htmltools::HTML(
    '
.info-value-box-grid {display:grid;grid-template-columns:repeat(var(--info-columns,2),minmax(0,1fr));gap:16px;align-items:stretch;margin:0;}
.info-value-box {box-sizing:border-box;min-width:0;margin:0;padding:20px;display:flex;flex-direction:column;gap:14px;background:var(--info-bg,#f2f7fb);color:var(--info-fg,#172c40);border:1px solid var(--info-border,#547a99);border-top:4px solid var(--info-accent,#005eb8);border-radius:5px;font-family:Arial,sans-serif;font-size:16px;line-height:1.5;}
.info-value-box .info-value-box-heading {display:flex;align-items:center;gap:12px;margin:0;}
.info-value-box .info-value-box-icon-wrap {display:flex;align-items:center;flex:0 0 auto;color:var(--info-accent,#005eb8);}
.info-value-box .info-value-box-icon {display:block;flex-shrink:0;}
.info-value-box .info-value-box-topic {margin:0;padding:0;border:0;color:var(--info-headline,#003e73);font-size:20px;font-weight:700;line-height:1.3;}
.info-value-box p {margin:0;}
.info-value-box .info-value-box-value {display:flex;align-items:baseline;flex-wrap:wrap;gap:9px;color:var(--info-headline,#003e73);}
.info-value-box .info-value-box-number {font-size:38px;font-weight:700;line-height:1.1;letter-spacing:-1px;}
.info-value-box .info-value-box-direction {font-size:18px;font-weight:700;}
.info-value-box .info-value-box-comparison {font-size:17px;line-height:1.5;}
.info-value-box .info-value-box-comparison strong {font-weight:700;}
.info-value-box .info-value-box-vs {color:var(--info-muted,#40566b);}
.info-value-box .info-value-box-measure {margin-top:auto;padding-top:12px;font-size:14px;color:var(--info-muted,#40566b);border-top:1px solid var(--info-divider,#c9d8e4);}
@media(max-width:640px) {.info-value-box-grid {grid-template-columns:minmax(0,1fr);}}
'
  ))
}

# Four cards default to 2x2; two or three default to a single row.
# Override columns in the Quarto document. All configurations stack on mobile.
info_value_box_layout <- function(..., columns = NULL) {
  boxes <- list(...)
  if (!length(boxes)) {
    stop("Supply at least one value box.")
  }
  if (is.null(columns)) {
    columns <- if (length(boxes) <= 3L) length(boxes) else 2L
  }
  stopifnot(
    is.numeric(columns),
    length(columns) == 1L,
    is.finite(columns),
    columns >= 1,
    columns == as.integer(columns)
  )
  htmltools::tags$div(
    class = "info-value-box-grid",
    style = paste0("--info-columns:", columns, ";"),
    boxes
  )
}

#' Create a compact key-fact card (htmltools article, replacing bslib::value_box).
#' type="group" covers sex, age, remoteness and socioeconomic comparisons.
#' group is the focal/numerator group; reference is the comparison group.
#' Percent values are signed relative differences, not percentage points.
#' Ratios are displayed directly: e.g. 0.5x the rate, without inversion.
#' type="trend" uses signed percentage change between from and to.
#' Rounded zero differences/changes have neutral wording; this does not imply
#' statistical significance. No significance claim is made for any comparison.
#' icon overrides the default with an HTML tag, or FALSE to omit the icon.
#' Colour arguments accept CSS colours. Include info_value_box_styles() once.
#' ... supplies HTML article attributes (e.g. id), not bslib options.
info_value_box <- function(
  condition,
  value,
  type = c("group", "trend"),
  measure = "Standardised mortality rates",
  group = "Males",
  reference = "Females",
  stat = c("percent", "ratio"),
  from = NULL,
  to = NULL,
  digits = 1,
  bg = "#f2f7fb",
  fg = "#172c40",
  icon = NULL,
  icon_size = "36px",
  conditions = health_conditions,
  accent = "#005eb8",
  border = "#547a99",
  headline = "#003e73",
  muted = "#40566b",
  divider = "#c9d8e4",
  ...
) {
  type <- match.arg(type)
  stat <- match.arg(stat)
  stopifnot(
    is.character(condition),
    length(condition) == 1L,
    !is.na(condition),
    nzchar(trimws(condition)),
    is.numeric(value),
    length(value) == 1L,
    is.finite(value),
    is.numeric(digits),
    length(digits) == 1L,
    is.finite(digits),
    digits >= 0,
    digits <= 10,
    digits == as.integer(digits)
  )
  label <- function(x, name) {
    if (
      is.null(x) ||
        length(x) != 1L ||
        is.na(x) ||
        !nzchar(trimws(as.character(x)))
    ) {
      stop("`", name, "` must be a non-empty label.")
    }
    as.character(x)
  }
  measure <- label(measure, "measure")
  normalise <- function(x) tolower(gsub("-", " ", trimws(x), fixed = TRUE))
  idx <- match(normalise(condition), normalise(names(conditions)))
  icon_name <- if (is.na(idx)) "medical_information" else conditions[[idx]]
  topic <- if (normalise(condition) == "all cause mortality") {
    "All-cause mortality"
  } else {
    condition
  }
  if (is.null(icon)) {
    icon <- material_symbol(icon_name, icon_size)
  }
  fmt <- function(x) formatC(x, format = "f", digits = digits)
  tags <- htmltools::tags
  if (type == "group") {
    group <- label(group, "group")
    reference <- label(reference, "reference")
    if (stat == "ratio") {
      if (value <= 0) {
        stop("`value` must be > 0 for a ratio.")
      }
      number <- paste0(fmt(value), "\u00d7")
      direction <- "the rate"
    } else {
      number <- paste0(fmt(abs(value)), "%")
      direction <- if (round(value, digits) == 0) {
        "difference"
      } else if (value > 0) {
        "higher"
      } else {
        "lower"
      }
    }
    comparison <- tags$p(
      class = "info-value-box-comparison",
      tags$strong(group),
      " ",
      tags$span(class = "info-value-box-vs", "vs"),
      " ",
      reference
    )
  } else {
    from <- label(from, "from")
    to <- label(to, "to")
    number <- paste0(fmt(abs(value)), "%")
    direction <- if (round(value, digits) == 0) {
      "change"
    } else if (value > 0) {
      "increase"
    } else {
      "decrease"
    }
    comparison <- tags$p(
      class = "info-value-box-comparison",
      tags$strong(
        from,
        " ",
        tags$span(`aria-hidden` = "true", "\u2192"),
        tags$span(
          style = "position:absolute;width:1px;height:1px;overflow:hidden;clip-path:inset(50%);white-space:nowrap;",
          " to "
        ),
        " ",
        to
      )
    )
  }
  colours <- c(
    bg = bg,
    fg = fg,
    accent = accent,
    border = border,
    headline = headline,
    muted = muted,
    divider = divider
  )
  style <- paste0("--info-", names(colours), ":", colours, ";", collapse = "")
  tags$article(
    class = "info-value-box",
    style = style,
    tags$header(
      class = "info-value-box-heading",
      if (!identical(icon, FALSE)) {
        tags$span(
          class = "info-value-box-icon-wrap",
          `aria-hidden` = "true",
          icon
        )
      },
      tags$h3(class = "info-value-box-topic", topic)
    ),
    tags$p(
      class = "info-value-box-value",
      tags$span(class = "info-value-box-number", number),
      " ",
      tags$span(class = "info-value-box-direction", direction)
    ),
    comparison,
    tags$p(class = "info-value-box-measure", measure),
    ...
  )
}
