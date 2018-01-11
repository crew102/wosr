context("Incites client")

test_that("pull_incites works for a small number of uts", {

  skip_on_cran()
  uts <- c(
    "000269886100018", "000272059500002", "000265594300007",
    "000270070100003", "000266574100004", "000270437500002",
    "000264727400025", "000270421600005", "000262493800001"
  )
  out_incites <- pull_incites(uts)
  expect_true(nrow(out_incites) == length(uts))

})

# test_that("pull_incites works for a large number of uts", {
#   skip_on_cran()
#   data_out <- pull_wos("TS = (dog welfare)")
#   out_incites_2 <- pull_incites(data_out$publication$ut)
#   expect_true(nrow(out_incites_2) > 1000)
# })
