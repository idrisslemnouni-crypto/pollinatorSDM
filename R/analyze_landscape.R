#' Analyze landscape metrics
#' @param rasters SpatRaster
#' @return list
#' @export
analyze_landscape <- function(rasters) {
  list(
    n_patches = terra::nrow(rasters) * terra::ncol(rasters) / 1000,
    mean_patch_size = mean(terra::values(rasters[[3]]), na.rm = TRUE),
    natural_habitat_ratio = mean(terra::values(rasters[[3]]) %in% c(1, 2), na.rm = TRUE)
  )
}
