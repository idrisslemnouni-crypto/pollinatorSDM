#' Calculate pollination index
#' @param raster_list List of SpatRaster (one per species)
#' @return SpatRaster
#' @export
calculate_pollination_index <- function(raster_list) {
  s <- terra::rast(raster_list)
  terra::mean(s, na.rm = TRUE)
}
