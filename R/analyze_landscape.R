#' Analyze landscape
#'
#' Analyse la fragmentation des habitats et les métriques paysagères.
#'
#' @param env_rasters SpatRaster stack environnemental
#' @return list de métriques paysagères
#' @export
analyze_landscape <- function(env_rasters) {
  lc_names <- c("landcover", "trees", "grassland", "shrubs", "cropland")
  lc_idx <- which(names(env_rasters) %in% lc_names)[1]

  if (is.na(lc_idx)) {
    stop("No landcover layer found in environmental rasters.")
  }

  landcover <- env_rasters[[lc_idx]]

  if (terra::is.bool(landcover)) {
    landcover <- as.numeric(landcover)
  }

  habitat <- landcover > 0.1
  habitat_int <- as.numeric(habitat)

  patches <- terra::patches(habitat_int, directions = 8, zeroAsNA = TRUE)
  patch_sizes <- terra::freq(patches)
  patch_sizes <- patch_sizes[patch_sizes$value > 0, ]

  if (nrow(patch_sizes) == 0) {
    return(list(
      n_patches = 0,
      mean_patch_size = NA,
      max_patch_size = NA,
      total_habitat_area = 0,
      distance_to_habitat = NA
    ))
  }

  cell_area <- terra::cellSize(patches, unit = "km")[[1]][1] * 100

  mean_patch_size <- mean(patch_sizes$count) * cell_area
  max_patch_size <- max(patch_sizes$count) * cell_area
  total_habitat_area <- sum(patch_sizes$count) * cell_area

  dist_to_habitat <- terra::gridDist(habitat_int, target = 1)

  list(
    n_patches = nrow(patch_sizes),
    mean_patch_size = mean_patch_size,
    max_patch_size = max_patch_size,
    total_habitat_area = total_habitat_area,
    distance_to_habitat = dist_to_habitat,
    patches_raster = patches
  )
}
