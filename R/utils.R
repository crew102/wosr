check_resp <- function(response) {
  if (httr::http_error(response)) {
    stop(parse_er(response), call. = FALSE)
  }
}

parse_er <- function(response) {
  doc <- get_xml(response)
  parse_el_txt(doc, xpath = "//faultstring")
}

lapply2 <- function(...) sapply(..., simplify = FALSE, USE.NAMES = TRUE)

replace_if_0_rows <- function(x, replace = NULL) {
  if (is.data.frame(x)) {
    if (nrow(x) == 0) return(replace)
  }
  x
}

ua <- function() httr::user_agent("https://github.com/vt-arc/wosr")

format_num <- function(x) format(
  x, big.mark = ",", scientific = FALSE, trim = TRUE
)

append_class <- function(x, class) structure(x, class = c(class(x), class))

trim_uts <- function(x) gsub("^WOS:", "", x, ignore.case = TRUE)

retry_throttle <- function(expr) {
  tryCatch(
    expr = expr,
    error = function(e) {
      throt_er <- grepl(
        "throttle|limit of [0-9] requests per period", e$message,
        ignore.case = TRUE
      )
      if (throt_er) {
        Sys.sleep(3)
        message("\nRan into throttling error. Sleeping and trying again.")
        expr
      } else {
        stop(e$message)
      }
    }
  )
}
