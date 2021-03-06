context("WoS clients")

test_that("authentication works", {
  expect_true(is.character(auth()))
})

sid <- auth()

test_that("Wos clients work as expected for regular result sets", {

  query <- "TS = (\"dog welfare\")"

  # Test querying of WOS
  qry_res <- query_wos(query, sid = sid)
  rec_cnt <- as.numeric(qry_res$rec_cnt)
  expect_gt(rec_cnt, 10)

  # Test pulling of WOS data (includes parsing step)
  data_out <- pull_wos(query, sid = sid)
  expect_equal(nrow(data_out$publication), rec_cnt)

  dfs_have_rows <- vapply(data_out, function(x) nrow(x) != 0, logical(1))
  expect_true(all(dfs_have_rows))
})

test_that("Wos clients work as expected for small result sets", {
  out <- pull_wos("UT=(000272366800025 OR 000272877700013)", sid = sid)
  expect_true(is.list(out))
})
