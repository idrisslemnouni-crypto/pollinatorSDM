#' Prepare environmental predictors
#' @param occurrences data.frame or sf or list
#' @param rasters SpatRaster
#' @return data.frame
#' @export
prepare_predictors <- function(occurrences, rasters) {
  if (is.list(occurrences) && all(c("cleaned", "report") %in% names(occurrences))) {
    occurrences <- occurrences$cleaned
  }
  occ_df <- as.data.frame(occurrences)
  if ("geometry" %in% names(occ_df)) {
    occ_df$geometry <- NULL
  }
  vals <- terra::extract(rasters, terra::vect(occurrences))
  vals$ID <- NULL
  cbind(occ_df, vals)
}
