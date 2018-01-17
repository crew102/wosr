## ---- eval = FALSE-------------------------------------------------------
#  library(wosr)
#  library(dplyr)
#  
#  data <- pull_wos("TS = \"dog welfare\"")
#  
#  data$author %>%
#    left_join(data$author_address, by = c("ut", "author_no")) %>%
#    left_join(data$address, by = c("ut", "addr_no"))

