#' Analyze landscape metrics
#' @param rasters SpatRaster with landcover layer
#' @return data.frame
#' @export
analyze_landscape <- function(rasters) {
  lc <- rasters[[3]]
  natural <- lc %in% c(1, 2)
  patches <- terra::patches(natural, directions = 8)
  f <- terra::freq(patches)
  sizes <- f[!is.na(f[,2]) & f[,2] > 0, 3]

  semi <- lc %in% c(3)
  dist <- terra::gridDistance(semi, origin = 1)

  data.frame(
    n_patches = length(sizes),
    mean_patch_size = mean(sizes),
    max_patch_size = max(sizes),
    total_natural_ha = sum(sizes),
    mean_dist_semi_natural_km = mean(terra::values(dist), na.rm = TRUE) / 1000,
    fragmentation_index = length(sizes) / sum(sizes)
  )
}
