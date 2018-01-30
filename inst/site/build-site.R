swap_render_fun <- function() {

  # Alter pkgdown:::build_rmarkdown_format
  build_rmarkdown_format2 <- function(pkg = ".",
                                      depth = 1L,
                                      data = list(),
                                      toc = TRUE) {
    path <- tempfile(fileext = ".html")
    suppressMessages(
      pkgdown::render_page(pkg, "vignette", data, path, depth = depth)
    )
    list(
      path = path,
      format = rmarkdown::html_document(
        toc = toc,
        toc_depth = 2,
        self_contained = FALSE,
        theme = NULL,
        template = path,
        df_print = "paged" # line added by crew102
      )
    )
  }
  # old_fun <- get("build_rmarkdown_format", envir = asNamespace("pkgdown"))
  # attributes(build_rmarkdown_format2) <- attributes(old_fun)
  assignInNamespace(
    "build_rmarkdown_format", build_rmarkdown_format2, ns = "pkgdown"
  )
}

build_site <- function() {
  # Render extra vignettes and move vignettes for pkgdown to pick up
  extra_vigs <- list.files(
    "inst/site/vignettes", full.names = TRUE, pattern = "\\.Rmd|\\.png"
  )
  to <- gsub("inst/site/vignettes", "vignettes/", extra_vigs)
  on.exit(try(unlink(x = to, force = TRUE)))
  file.copy(extra_vigs, to = to)

  # Change render function in pkgdown so it uses paged df printing
  swap_render_fun()

  # Build site
  pkgdown::build_site()
}