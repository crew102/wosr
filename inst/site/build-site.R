build_site <- function() {
  # Render extra vignettes and move vignettes for pkgdown to pick up
  extra_vigs <- list.files(
    "inst/site/vignettes", full.names = TRUE, pattern = "\\.Rmd|\\.png"
  )
  to <- gsub("inst/site/vignettes", "vignettes/", extra_vigs)
  on.exit(try(unlink(x = to, force = TRUE)))
  file.copy(extra_vigs, to = to)

  pkgdown::build_site()
}
