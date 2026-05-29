#' Download pollinator occurrence data
#' @param species Character vector of species names
#' @param limit Integer, max records per species
#' @return data.frame of occurrences
#' @export
download_pollinator_data <- function(species = c("Apis mellifera", "Bombus terrestris"), limit = 100) {
  message("Simulating GBIF download...")
  data <- do.call(rbind, lapply(species, function(sp) {
    data.frame(species = sp, decimalLongitude = runif(limit, -10, 20), decimalLatitude = runif(limit, 30, 50), year = 2020)
  }))
  data
}
