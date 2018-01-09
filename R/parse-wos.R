parse_wos <- function(all_resps) {
  pbapply::pblapply(all_resps, one_parse)
}

# Parse one resposnes and place results into list
one_parse <- function(response) {

  # Create html parse tree
  doc <- get_xml(response)

  # Get nodes corresponding to each publication
  doc_list <- xml_find_all(doc, "//rec")

  # Parse data
  list(
    pub_parselist = parse_gen_pub_data(doc_list),
    author_parselist = parse_author_node_data(doc_list),
    address_parselist = parse_address_node_data(doc_list)
  )
}

# Function to pull out data from elements (and their attributes) that don't
# require we care about their ancestor nodes (beyond the fact that they exist
# in a given rec node)
parse_gen_pub_data <- function(doc_list) {

  pub_els <- c(
    ut = ".//uid[1]", # document id
    title = ".//summary//title[@type='item'][1]", # title
    journal = ".//summary//title[@type='source'][1]", # journal
    doc_type = ".//summary//doctype[1]", # doc type
    abstract = ".//fullrecord_metadata//p[ancestor::abstract_text]", # abstract
    jsc = ".//fullrecord_metadata//subject[@ascatype='traditional']", # JSCs
    keyword = ".//fullrecord_metadata//keyword", # keywords
    keywords_plus = ".//static_data//keywords_plus/keyword", # keywords plus
    grant_number = ".//fullrecord_metadata//grant_id", # grant numbers
    grant_agency = ".//fullrecord_metadata//grant_agency" # grant orgs
  )
  pub_els_out <- parse_els_apply(doc_list, xpath = pub_els)

  pub_atrs <- c(
    sortdate = ".//summary//pub_info[1]", # publication's pub date
    value = ".//dynamic_data//identifier[@type='doi'][1]", # publication's DOI
    local_count = ".//citation_related//silo_tc[1]" # times cited
  )
  pub_atr_out <- parse_atrs_apply(doc_list, xpath = pub_atrs)

  bind_el_atr(pub_els_out, pub_atr_out)
}

# For each pub, find the nodes containing author data and extract the relevant
# child node values and attributes from those nodes
parse_author_node_data <- function(doc_list) {

  author_list <- split_nodes(
    doc_list,
    xpath = ".//summary//names//name[@role='author' and child::wos_standard and string-length(@seq_no)>0]"
  )

  el_xpath <- c(
    display_name = "display_name[1]", # display name (e.g., baker, chris)
    first_name = "first_name[1]",
    last_name = "last_name[1]",
    email = "email_addr[1]" # author's email
  )
  atr_xpath <- c(
    seq_no = ".", # author's listing sequence
    daisng_id = ".", # author's DaisNG ID
    addr_no = "." # Authors address number, for linking to address data
  )

  parse_deep(author_list, el_xpath, atr_xpath)
}

# For each pub, find the nodes containing address data and extract the relevant
# child node values and attributes from those nodes
parse_address_node_data <- function(doc_list) {

  address_list <- split_nodes(
    doc_list,
    xpath = ".//fullrecord_metadata//addresses/address_name/address_spec"
  )

  el_xpath <- c(
    org_pref = "./organizations/organization[@pref='Y'][1]", # preferred name of org
    org = "./organizations/organization[not(@pref='Y')][1]", # regular name of org
    city = "city[1]", # org city
    state = "state[1]", # org state
    country = "country[1]" # org country
  )
  atr_xpath <- c(addr_no = ".")

  parse_deep(address_list, el_xpath, atr_xpath)
}

## utility parsing functions
get_xml <- function(response) {
  raw_xml <- httr::content(response, "text")
  unescaped_xml <- unescape_xml(raw_xml)
  unescaped_xml <- paste0("<x>", unescaped_xml, "</x>")
  read_html(unescaped_xml)
}

unescape_xml <- function(x) {
  # x <- gsub("&apos;", "'", x)
  x <- gsub("&lt;", "<", x)
  x <- gsub("&gt;", ">", x)
  gsub("&amp;", "&", x)
}

split_nodes <- function(doc_list, xpath)
  lapply(doc_list, function(x) xml_find_all(x, xpath))

parse_deep <- function(entity_list, el_xpath, atr_xpath) {
  lapply(entity_list, function(x) {
    one_ent_data <- lapply(x, function(q) {
      els <- parse_els(q, xpath = el_xpath)
      atrs <- parse_atrs(q, xpath = atr_xpath)
      unlist(c(els, atrs))
    })
    do.call(rbind, one_ent_data)
  })
}

parse_els_apply <- function(doc_list, xpath)
  lapply(doc_list, function(x) parse_els(x, xpath = xpath))

parse_els <- function(doc, xpath)
  lapply(xpath, function(x) parse_el_txt(doc, x))

parse_el_txt <- function(doc, xpath) {
  txt <- xml_text(xml_find_all(doc, xpath))
  na_if_missing(txt)
}

parse_atrs_apply <- function(doc_list, xpath)
  lapply(doc_list, function(x) parse_atrs(x, xpath = xpath))

parse_atrs <- function(doc, xpath) {
  lapply2(names(xpath), function(x) {
    el <- xml_find_all(doc, xpath[[x]])
    atr_out <- xml_attr(el, attr = x)
    na_if_missing(atr_out)
  })
}

na_if_missing <- function(x) if (is.null(x) || length(x) == 0) NA else x

bind_el_atr <- function(el_list, atr_list)
  lapply(seq_along(el_list), function(x) c(el_list[[x]], atr_list[[x]]))
