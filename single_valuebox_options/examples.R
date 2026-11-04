# Run from this folder. Reuses the latest reduced-footprint component.
source("../original_design_20pct/info_valuebox.R")
config <- read_value_box_config("../valuebox_config.csv")
statements <- readr::read_csv("../original_design_20pct/example_statements_short.csv", show_col_types = FALSE)
fact <- function() info_value_box(
  title = "Risky drinking", value = "2.0\u00d7", value_note = "the proportion",
  type = "comparative", demographic_var = "sex", context = "Males vs females",
  description = statements$example_statement[[1]], config = config
)
options <- list(
  full = c("1. Full width", "Spans the same 44rem region as two cards, including their gap. Strong page alignment, but leaves more space beside a short fact."),
  capped = c("2. Capped width, aligned left", "Up to 28rem (448px). Suggested default: keeps the fact compact and aligned with the narrative while allowing more room than a standard column."),
  centred = c("3. Capped width, centred", "The same 28rem cap, centred in the page. Useful for a featured fact; breaks the left alignment used by the narrative."),
  column = c("4. One standard column", "Matches one card in the two-card layout: (available width minus the 0.375rem gap) / 2. Preserves card size, with deliberate empty space on the right."),
  horizontal = c("5. Full width, horizontal content", "Uses the full region, placing the statement beside the statistic on wide screens. A compact banner alternative; returns to the original vertical structure in narrow containers.")
)
example <- function(key) {
  htmltools::tags$section(
    htmltools::tags$h2(options[[key]][[1]]),
    htmltools::tags$p(options[[key]][[2]]),
    htmltools::tags$div(class = "page-sample",
      htmltools::tags$h3("Alcohol consumption"),
      htmltools::tags$div(class = paste0("single-box-demo single-box-demo--", key),
        info_value_box_layout(fact())),
      htmltools::tags$h4("Patterns of consumption"),
      htmltools::tags$p("Alcohol consumption varies across population groups. The narrative and dashboard would continue here, aligned with the page text column.")
    )
  )
}
comparison <- function() htmltools::tagList(
  htmltools::tags$h2("Reference: two valueboxes"),
  htmltools::tags$p("The same fact is repeated here only to show the existing two-column width and gap."),
  info_value_box_layout(fact(), fact()),
  lapply(names(options), example)
)
