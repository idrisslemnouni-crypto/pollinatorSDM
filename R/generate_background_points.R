#' Generate background points
#' @param rasters SpatRaster
#' @param n Integer, number of points
#' @return data.frame
#' @export
generate_background_points <- function(rasters, n = 1000) {
  pts <- terra::spatSample(rasters, size = n, method = "random", values = TRUE, xy = TRUE, na.rm = TRUE)
  pts$presence <- 0
  pts
}
