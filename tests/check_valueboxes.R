# Run from the project root: Rscript tests/check_valueboxes.R
source("info_valuebox.R")
config <- read_value_box_config()
stopifnot(nrow(config) == 17L)

expect_error <- function(expr, pattern) {
  error <- tryCatch({ force(expr); NULL }, error = identity)
  stopifnot(inherits(error, "error"), grepl(pattern, conditionMessage(error)))
}

# Every configured category and both trend directions must produce the
# configured colour and icon, without relying on the prose or numeric sign.
for (i in seq_len(nrow(config))) {
  row <- config[i, ]
  directions <- if (row$type == "trend") c("increase", "decrease") else NA_character_
  for (direction in directions) {
    box <- info_value_box("Topic", "10%", row$type, row$demographic_var,
                          "Population", "Full statement", config,
                          direction = if (is.na(direction)) NULL else direction)
    expected_icon <- if (is.na(direction) || direction == "increase") row$icon else
      row$icon_decrease
    html <- as.character(box)
    stopifnot(grepl(row$highlight_colour, html, fixed = TRUE),
              grepl(paste0("bi-", expected_icon, " "), html, fixed = TRUE))
  }
}

box <- info_value_box("<script>alert(1)</script>", "10%", "comparative", "sex",
                      "A & B", "Statement", config)
stopifnot(grepl("&lt;script&gt;", as.character(box), fixed = TRUE),
          !grepl("<script>alert", as.character(box), fixed = TRUE))
comparison <- info_value_box("Comparison", "2.0x", "comparative", "sex",
                             "Males & boys vs females <18", "Statement", config)
stopifnot(grepl('<strong class="info-value-box-focal">Males &amp; boys</strong>',
               as.character(comparison), fixed = TRUE),
          grepl("females &lt;18", as.character(comparison), fixed = TRUE))
for (n in 1:5) {
  boxes <- rep(list(box), n)
  columns <- if (n <= 3L) n else 2L
  html <- as.character(info_value_box_layout(boxes))
  stopifnot(grepl(paste0("repeat(", columns, ","), html, fixed = TRUE))
}
stopifnot(identical(as.character(info_value_box_layout(box, box)),
                    as.character(info_value_box_layout(list(box, box)))))
expect_error(info_value_box_layout(), "at least one")
expect_error(info_value_box("Topic", "10%", "comparative", "unknown",
                            "Context", "Statement", config), "Expected one config row")
expect_error(info_value_box("Topic", "10%", "trend", "persons",
                            "Context", "Statement", config), "require direction")

# Exercise mistakes that otherwise silently produce the wrong category style.
check_bad_config <- function(config, pattern) {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path))
  readr::write_csv(config, path)
  expect_error(read_value_box_config(path), pattern)
}
check_bad_config(rbind(config, config[1, ]), "duplicate")
bad <- config
bad$highlight_colour[1] <- "purple"
check_bad_config(bad, "hex colours")
bad <- config
bad$icon[1] <- "not-a-bootstrap-icon"
check_bad_config(bad, "Unknown Bootstrap icon")

# Contrast of context text on the fixed white card background (WCAG formula).
rgb <- grDevices::col2rgb(config$highlight_colour) / 255
linear <- ifelse(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
luminance <- colSums(linear * c(0.2126, 0.7152, 0.0722))
stopifnot(all(1.05 / (luminance + 0.05) >= 4.5))
cat("Passed: all config categories, trend icons, layout counts, text escaping,\n",
    "invalid configuration handling and default text contrast.\n")
