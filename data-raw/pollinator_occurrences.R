set.seed(42)
pollinator_occurrences <- data.frame(
  species = rep(c("Apis mellifera", "Bombus terrestris"), each = 50),
  decimalLongitude = c(runif(50, -10, 10), runif(50, -5, 15)),
  decimalLatitude = c(runif(50, 30, 45), runif(50, 35, 50)),
  year = 2020
)
usethis::use_data(pollinator_occurrences, overwrite = TRUE)
