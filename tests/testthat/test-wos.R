context("WoS")

test_that("authentication works", {
  skip_if_no_auth()
  # reuse sid across tests, so we don't run into throttling limits. note that
  # this has to be inside test_that function so we can use skip_if_no_auth()
  if (!exists("sid")) sid <<- auth()
  expect_true(is.character(sid))
})

query <- "TS = (\"dog welfare\")"

test_that("Wos clients work as expected for regular result sets", {
  skip_if_no_auth()

  # Test querying of WOS
  qry_res <- query_wos(query, sid = sid)
  expect_gt(qry_res$rec_cnt, 10)

  # Test pulling of WOS data (includes parsing step)
  data_out <- pull_wos(query, sid = sid)
  expect_equal(nrow(data_out$publication), qry_res$rec_cnt)

  dfs_have_rows <- vapply(data_out, function(x) nrow(x) != 0, logical(1))
  expect_true(all(dfs_have_rows))
})

test_that("pull_wos works as expected for small result sets", {
  skip_if_no_auth()
  out <- pull_wos("UT=(000259281900002)", sid = sid)
  expect_true(is.list(out))
  expect_true(is_empty_df(out$grant))
})

test_that("pull_wos returns list of zero-length dfs when query doesn't match", {
  skip_if_no_auth()
  out <- pull_wos("UT=(0002723668000)", sid = sid)
  all_e <- vapply(out, is_empty_df, logical(1))
  expect_true(all(all_e))
})

test_that("IO functions work as expected", {
  skip_if_no_auth()

  wos_data <- pull_wos(query, sid = sid)
  dir <- tempdir()

  write_wos_data(wos_data, dir)
  wos_data_read <- read_wos_data(dir)

  are_equal <- all.equal(wos_data, wos_data_read)
  expect_true(isTRUE(are_equal))
})

queries <- c(query, "TS = (\"cat welfare\")")

test_that("pull_wos_apply returns expected `query` data frame", {
  skip_if_no_auth()

  q_names <- c("dog welf", "cat welf")
  names(queries) <- q_names
  out <- pull_wos_apply(queries, sid = sid)

  expect_true(nrow(out$query) > 0)
  expect_true(identical(unique(out$query$query), q_names))
})

test_that("query_wos_apply returns data frame with query results", {
  skip_if_no_auth()

  out <- query_wos_apply(queries, sid = sid)

  expect_true(nrow(out) == 2)
  expect_true(all(out$rec_cnt > 10))
})

test_that("pull_cited_refs returns data for pubs with cited refs", {
  skip_if_no_auth()

  uts <- c("WOS:000362312600021", "WOS:000439855300030", "WOS:000294946900020")
  out <- pull_cited_refs(uts, sid)

  expect_true(all(uts %in% out$ut))
  Sys.sleep(1)
})

test_that("pull_cited_refs returns no data for pubs with no cited refs", {
  skip_if_no_auth()

  uts <- c("WOS:000346263300011", "WOS:000279885800004", "11")
  out <- pull_cited_refs(uts, sid)

  expect_true(nrow(out) == 0)
})

test_that("pull_related_recs returns data for pubs with related recs", {
  skip_if_no_auth()

  uts <- c("WOS:000272877700013", "WOS:000272366800025")
  out <- pull_related_recs(uts, 5, sid = sid)

  expect_true(nrow(out) == 10 && all(uts %in% out$ut))
  Sys.sleep(1)
})

test_that("pull_related_recs returns no data for pubs with no related recs", {
  skip_if_no_auth()

  out <- pull_related_recs("000346263300011", 5, sid = sid)
  expect_true(nrow(out) == 0)
})
