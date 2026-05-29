#' Clean occurrence data
#' @param occurrences data.frame
#' @return list with cleaned data and report
#' @export
clean_occurrences <- function(occurrences) {
  n_before <- nrow(occurrences)
  occurrences <- occurrences[!is.na(occurrences$decimalLongitude) & !is.na(occurrences$decimalLatitude), ]
  occurrences <- occurrences[!duplicated(occurrences[, c("decimalLongitude", "decimalLatitude")]), ]
  n_after <- nrow(occurrences)

  report <- data.frame(
    n_before = n_before,
    n_after = n_after,
    n_removed = n_before - n_after,
    duplicates_removed = n_before - n_after
  )

  sf::st_as_sf(occurrences, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
  list(cleaned = sf::st_as_sf(occurrences, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326), report = report)
}
