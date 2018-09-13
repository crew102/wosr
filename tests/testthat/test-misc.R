context("Misc funs")

sid <- auth()

test_that("IO functions work as expected", {

  skip_if_no_auth()
  wos_data <- pull_wos(query <- "TS = (\"dog welfare\")", sid = sid)
  dir <- tempdir()

  write_wos_data(wos_data, dir)
  wos_data_read <- read_wos_data(dir)

  are_equal <- all.equal(wos_data, wos_data_read)
  expect_true(isTRUE(are_equal))
})

test_that("pull_wos_apply returns expected `query` data frame", {

  skip_if_no_auth()

  queries <- c('TS="dog welfare"', 'TS="cat welfare"')
  q_names <- c("dog welf", "cat welf")
  names(queries) <- q_names
  out <- pull_wos_apply(queries, sid = sid)

  expect_true(nrow(out$query) > 0)
  expect_true(identical(unique(out$query$query), q_names))
})

test_that("query_wos_apply returns data frame with query results", {

  skip_if_no_auth()

  queries <- c('TS="dog welfare"', 'TS="cat welfare"')
  out <- query_wos_apply(queries, sid = sid)

  expect_true(nrow(out) == 2)
  expect_true(all(out$rec_cnt > 10))
})
