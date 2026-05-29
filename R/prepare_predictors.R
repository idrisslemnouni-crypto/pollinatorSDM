#' Prepare environmental predictors for SDM
#' @param occurrences sf object
#' @param rasters SpatRaster
#' @return data.frame
#' @export
prepare_predictors <- function(occurrences, rasters) {
  vals <- terra::extract(rasters, terra::vect(occurrences))
  cbind(as.data.frame(occurrences), vals[, -1])
}
