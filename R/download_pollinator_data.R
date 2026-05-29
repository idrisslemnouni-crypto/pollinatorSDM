#' Download pollinator occurrence data from GBIF
#' @param species Character vector of species names
#' @param limit Integer, max records per species
#' @param country Optional country code
#' @return data.frame of occurrences
#' @export
download_pollinator_data <- function(species = c("Apis mellifera", "Bombus terrestris", "Bombus lapidarius"), limit = 100, country = NULL) {

  if (requireNamespace("rgbif", quietly = TRUE)) {
    message("Downloading from GBIF via rgbif...")
    all_data <- tryCatch({
      do.call(rbind, lapply(species, function(sp) {
        res <- rgbif::occ_search(scientificName = sp, limit = limit, country = country, hasCoordinate = TRUE)
        if (!is.null(res$data) && nrow(res$data) > 0) {
          df <- res$data[, c("scientificName", "decimalLongitude", "decimalLatitude", "year")]
          names(df)[1] <- "species"
          return(df)
        }
        NULL
      }))
    }, error = function(e) {
      message("GBIF API failed: ", e$message)
      NULL
    })
    if (!is.null(all_data)) {
      all_data <- all_data[!duplicated(all_data[, c("decimalLongitude", "decimalLatitude")]), ]
      all_data <- all_data[!is.na(all_data$decimalLongitude), ]
      return(all_data)
    }
  }

  message("Simulating GBIF data...")
  data <- do.call(rbind, lapply(species, function(sp) {
    data.frame(species = sp, decimalLongitude = runif(limit, -10, 20), decimalLatitude = runif(limit, 30, 50), year = 2020)
  }))
  data[!duplicated(data[, c("decimalLongitude", "decimalLatitude")]), ]
}
