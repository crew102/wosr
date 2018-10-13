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
