## ---- echo = FALSE, message = FALSE--------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  progress = FALSE,
  error = FALSE, 
  message = FALSE
)

options(digits = 2)

## ---- eval = FALSE-------------------------------------------------------
#  library(wosr)
#  sid <- auth(username = "your_username", password = "your_password")

## ---- echo = FALSE-------------------------------------------------------
library(wosr)
sid <- auth()

## ------------------------------------------------------------------------
# Find all publications that contain "animal welfare" in their titles (TI tag)
# and have the words "dog" and "welfare" somewhere in their titles, abstracts, or
# list of keywords (TS tag).
query <- 'TI = ("animal welfare") AND TS = (dog welfare)'
query_wos(query, sid = sid)

## ------------------------------------------------------------------------
data <- pull_wos(query, sid = sid)
data

## ------------------------------------------------------------------------
library(dplyr)

top_jscs <- 
  data$jsc %>% 
    group_by(jsc) %>% 
    count() %>% 
    arrange(desc(n)) %>% 
    head()

top_jscs

## ------------------------------------------------------------------------
data$jsc %>% 
  inner_join(top_jscs, by = "jsc") %>% 
  inner_join(data$publication, by = "ut") %>% 
  select(title) %>% 
  distinct() %>% 
  head()

## ------------------------------------------------------------------------
cat_pubs <- 
  data$publication %>% 
    filter(grepl("\\bcat\\b", abstract, ignore.case = TRUE)) %>% 
    select(ut, title)

cat_pubs

## ------------------------------------------------------------------------
cat_authors <- 
  data$author %>% 
    semi_join(cat_pubs, by = "ut") %>% 
    select(ut, author_no, display_name)

cat_authors

## ------------------------------------------------------------------------
cat_authors %>% 
  inner_join(data$author_address, by = c("ut", "author_no")) %>% 
  inner_join(data$address, by = c("ut", "addr_no")) %>% 
  select(ut, author_no, display_name, org)

## ------------------------------------------------------------------------
data$grant %>% 
  inner_join(data$publication, by = "ut") %>% 
  select(ut, tot_cites, grant_agency) %>% 
  distinct() %>% 
  arrange(desc(tot_cites)) %>% 
  head()

## ---- eval = FALSE-------------------------------------------------------
#  top_100_pubs <-
#    data$publication %>%
#      arrange(desc(tot_cites)) %>%
#      slice(1:100) %>%
#      .$ut
#  
#  head(pull_incites(top_100_pubs, key = "your_incites_key"))

## ---- echo = FALSE-------------------------------------------------------
top_100_pubs <- 
  data$publication %>% 
    arrange(desc(tot_cites)) %>% 
    slice(1:100) %>% 
    .$ut

head(pull_incites(top_100_pubs))

