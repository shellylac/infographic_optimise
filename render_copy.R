library(quarto)
library(fs)

#Render and copy
quarto_render("example_2x2.qmd")
file_copy(
  path = "example_2x2.html",
  new_path = "/popepi/phd_website/valuebox_mockups/example_2x2.html",
  overwrite = TRUE
)


# Copy the other templates
quarto_render("original_design_20pct/info_valuebox_example.qmd")
file_copy(
  path = "original_design_20pct/info_valuebox_example.html",
  new_path = "/popepi/phd_website/valuebox_mockups/info_valuebox_example.html",
  overwrite = TRUE
)

# Copy the other templates
quarto_render("single_valuebox_options/single_valuebox_example.qmd")
file_copy(
  path = "single_valuebox_options/single_valuebox_example.html",
  new_path = "/popepi/phd_website/valuebox_mockups/single_valuebox_example.html",
  overwrite = TRUE
)
