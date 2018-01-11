context("WoS clients")

test_that("authentication works", {
  skip_on_cran()
  # reuse sid across tests, so we don't run into throttling limits. note that
  # this has to be insdie test_that function, so we can use skip_on_cran.
  sid <<- auth()
  expect_true(is.character(sid))
})

test_that("Wos clients work as expected for regular result sets", {

  skip_on_cran()
  query <- "TS = (\"dog welfare\")"

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
  skip_on_cran()
  out <- pull_wos("UT=(000272366800025 OR 000272877700013)", sid = sid)
  expect_true(is.list(out))
})
