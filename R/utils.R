check_resp <- function(response, message) {
  if (httr::http_error(response)) {
    doc <- get_xml(response)
    stop(message, parse_el_txt(doc, xpath = "//faultstring"), call. = FALSE)
  }
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