#' Clean occurrence coordinates
#' @param df data.frame with decimalLongitude, decimalLatitude
#' @return sf object
#' @export
clean_occurrences <- function(df) {
  df <- df[!is.na(df$decimalLongitude) & !is.na(df$decimalLatitude), ]
  df <- df[!duplicated(df[, c("decimalLongitude", "decimalLatitude")]), ]
  sf::st_as_sf(df, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
}
