# HTML value boxes for Quarto (Bootstrap 5) and bslib pages.
# Dependencies: bslib, bsicons, htmltools, readr, dplyr.
# Include info_valuebox.css in the page's Quarto YAML. See README.md.

#' Read and validate the team's style lookup once, at page setup.
#' One row per type/demographic_var pair; icons are Bootstrap icon names.
read_value_box_config <- function(path = "valuebox_config.csv") {
  config <- readr::read_csv(
    path, col_types = readr::cols(.default = readr::col_character()),
    show_col_types = FALSE, trim_ws = TRUE
  )
  required <- c("type", "demographic_var", "highlight_colour", "icon",
                "icon_decrease")
  if (!all(required %in% names(config))) {
    stop("Config must contain: ", paste(required, collapse = ", "), call. = FALSE)
  }
  if (nrow(config) == 0L || anyNA(config[c("type", "demographic_var", "highlight_colour", "icon")]) ||
      any(!nzchar(config$type)) || any(!nzchar(config$demographic_var))) {
    stop("Config needs non-empty type, demographic_var, highlight_colour and icon values.", call. = FALSE)
  }
  if (any(!config$type %in% c("comparative", "trend", "domain_statistic"))) {
    stop("Config type must be comparative, trend or domain_statistic.", call. = FALSE)
  }
  if (anyDuplicated(config[c("type", "demographic_var")])) {
    stop("Config has duplicate type/demographic_var pairs.", call. = FALSE)
  }
  if (any(!grepl("^#[0-9A-Fa-f]{6}$", config$highlight_colour))) {
    stop("Use six-digit hex colours, e.g. #005EB8, in highlight_colour.", call. = FALSE)
  }
  trends <- dplyr::filter(config, .data$type == "trend")
  if (anyNA(trends$icon_decrease) || any(!nzchar(trends$icon_decrease))) {
    stop("Trend rows need icon_decrease as well as icon (increase).", call. = FALSE)
  }
  icons <- unique(unlist(config[c("icon", "icon_decrease")], use.names = FALSE))
  for (icon in icons[!is.na(icons) & nzchar(icons)]) {
    tryCatch(bsicons::bs_icon(icon), error = function(e) {
      stop("Unknown Bootstrap icon in config: ", icon, call. = FALSE)
    })
  }
  config
}

.value_box_text <- function(x, name) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(trimws(x))) {
    stop("`", name, "` must be a non-empty text string.", call. = FALSE)
  }
  x
}

#' Build one bslib value box. All display fields are literal text, not HTML.
#' value is already formatted, e.g. "25.5%" or "2.0\u00d7"; no statistics are calculated.
#' context is the highlighted population/comparison line.
#' For comparative boxes, use "Focal group vs reference group"; the focal
#' group is automatically larger and bolder. Other context text is used as-is.
#' description is the full statement, including the reporting period.
#' For trends, direction is required: increase or decrease.
#' value_note defaults to the trend direction; override for wording such as "lower".
#' config is the tibble returned by read_value_box_config().
#' The original template's comparison/domain_stat type names are accepted aliases.
info_value_box <- function(title, value, type, demographic_var, context,
                           description, config, value_note = NULL,
                           direction = NULL) {
  title <- .value_box_text(title, "title")
  value <- .value_box_text(value, "value")
  type <- .value_box_text(type, "type")
  demographic_var <- .value_box_text(demographic_var, "demographic_var")
  context <- .value_box_text(context, "context")
  description <- .value_box_text(description, "description")
  aliases <- c(comparison = "comparative", domain_stat = "domain_statistic")
  if (type %in% names(aliases)) type <- unname(aliases[[type]])
  style <- dplyr::filter(config, .data$type == .env$type,
                         .data$demographic_var == .env$demographic_var)
  if (nrow(style) != 1L) {
    stop("Expected one config row for type='", type,
         "', demographic_var='", demographic_var, "'.", call. = FALSE)
  }
  icon <- style$icon[[1]]
  if (type == "trend") {
    if (is.null(direction)) {
      stop("Trend boxes require direction: increase or decrease.", call. = FALSE)
    }
    direction <- match.arg(direction, c("increase", "decrease"))
    icon <- switch(direction, increase = style$icon[[1]],
                   decrease = style$icon_decrease[[1]])
    if (is.null(value_note)) {
      value_note <- direction
    }
  } else if (!is.null(direction)) {
    stop("`direction` is only used for trend boxes.", call. = FALSE)
  }
  if (!is.null(value_note)) value_note <- .value_box_text(value_note, "value_note")

  tags <- htmltools::tags
  if (type == "comparative") {
    comparison <- strsplit(context, "(?i)\\s+vs\\.?\\s+", perl = TRUE)[[1]]
    if (length(comparison) == 2L && all(nzchar(trimws(comparison)))) {
      context <- htmltools::tagList(
        tags$strong(class = "info-value-box-focal", trimws(comparison[[1]])),
        " vs ", trimws(comparison[[2]])
      )
    }
  }
  # Keep the icon in the title row so long titles wrap without constraining
  # the statistic or explanation to bslib's separate showcase column.
  bslib::value_box(
    title = tags$div(
      class = "info-value-box-heading",
      tags$span(class = "info-value-box-title", title),
      tags$span(class = "info-value-box-icon", `aria-hidden` = "true",
                bsicons::bs_icon(icon, size = "1em", a11y = "deco"))
    ),
    value = tags$p(
      tags$span(class = "info-value-box-number", value),
      if (!is.null(value_note)) tags$span(class = "info-value-box-note", paste0(" ", value_note))
    ),
    tags$p(class = "info-value-box-context", context),
    tags$p(class = "info-value-box-description", description),
    class = "info-value-box", fill = FALSE,
    style = paste0("--info-accent:", style$highlight_colour[[1]], ";")
  )
}

#' Lay out boxes: 4 -> 2x2; 3 -> 1x3; 2 -> 1x2; 1 -> full width.
#' Pass individual boxes or one list (e.g. from purrr::pmap()).
#' Larger sets use two columns. Narrow containers stack to one column.
info_value_box_layout <- function(...) {
  boxes <- list(...)
  if (length(boxes) == 1L && is.list(boxes[[1]]) &&
      !inherits(boxes[[1]], c("shiny.tag", "shiny.tag.list"))) {
    boxes <- boxes[[1]]
  }
  if (!length(boxes) || any(vapply(boxes, is.null, logical(1)))) {
    stop("Supply at least one value box; boxes must not be NULL.", call. = FALSE)
  }
  columns <- if (length(boxes) <= 3L) length(boxes) else 2L
  grid <- do.call(bslib::layout_column_wrap, c(
    unname(boxes), list(width = 1 / columns, heights_equal = "row",
                       fill = FALSE, gap = "0.75rem", class = "info-value-box-grid")
  ))
  htmltools::tags$div(class = "info-value-box-region", grid)
}
