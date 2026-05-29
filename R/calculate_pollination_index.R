#' Calculate pollination index
#' @param prediction_raster SpatRaster
#' @param env_rasters SpatRaster
#' @param crop_data Optional data.frame with dependence_pollination column
#' @return SpatRaster
#' @export
calculate_pollination_index <- function(prediction_raster, env_rasters, crop_data = NULL) {
  base_index <- terra::app(prediction_raster, fun = function(x) mean(x, na.rm = TRUE))

  if (!is.null(crop_data) && "dependence_pollination" %in% names(crop_data)) {
    mean_dep <- mean(crop_data$dependence_pollination, na.rm = TRUE)
    base_index <- base_index * mean_dep
  }

  names(base_index) <- "pollination_index"
  return(base_index)
}
