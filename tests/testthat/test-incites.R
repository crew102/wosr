# context("Incites client")
#
# test_that("pull_incites works for a small number of uts", {
#
#   skip_if_no_auth()
#   uts <- c(
#     "000269886100018", "000272059500002", "000265594300007",
#     "000270070100003", "000266574100004", "000270437500002",
#     "000264727400025", "000270421600005", "000262493800001"
#   )
#   out_incites <- pull_incites(uts)
#   expect_true(nrow(out_incites) == length(uts))
#
# })
