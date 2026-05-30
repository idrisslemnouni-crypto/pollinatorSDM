#' Summarize risk by region
#'
#' Agrège le déficit de pollinisation par région géographique (grille régulière).
#'
#' @param deficit_raster SpatRaster du déficit
#' @param crop_map sf object des cultures avec area_ha
#' @param grid_size numeric, taille de la grille en degrés (défaut 1)
#' @return data.frame avec statistiques par région
#' @export
summarize_risk_by_region <- function(deficit_raster, crop_map, grid_size = 1) {
  if (!requireNamespace("sf", quietly = TRUE)) stop("sf required")

  # Créer grille régulière sur l'extent du raster
  ext <- terra::ext(deficit_raster)
  grid_rast <- terra::rast(
    xmin = ext[1], xmax = ext[2], ymin = ext[3], ymax = ext[4],
    resolution = grid_size, crs = terra::crs(deficit_raster)
  )
  grid_rast[] <- seq_len(terra::ncell(grid_rast))
  names(grid_rast) <- "region_id"

  # Extraire statistiques déficit par région
  zonal_stats <- terra::zonal(deficit_raster, grid_rast, fun = "mean", na.rm = TRUE)
  zonal_max <- terra::zonal(deficit_raster, grid_rast, fun = "max", na.rm = TRUE)
  zonal_count <- terra::zonal(deficit_raster, grid_rast, fun = "count", na.rm = TRUE)

  # Agréger surfaces agricoles par région
  crop_vect <- terra::vect(crop_map)
  crop_vect <- terra::project(crop_vect, terra::crs(grid_rast))
  crop_extract <- terra::extract(grid_rast, crop_vect, df = TRUE, ID = FALSE)
  crop_map$region_id <- crop_extract[[1]]

  area_by_region <- stats::aggregate(area_ha ~ region_id, data = crop_map, FUN = sum, na.rm = TRUE)
  names(area_by_region) <- c("region_id", "total_crop_area_ha")

  # Combiner
  region_df <- data.frame(
    region_id = zonal_stats$region_id,
    mean_deficit = zonal_stats$pollination_deficit,
    max_deficit = zonal_max$pollination_deficit,
    n_cells = zonal_count$pollination_deficit
  )

  region_df <- merge(region_df, area_by_region, by = "region_id", all.x = TRUE)
  region_df$total_crop_area_ha[is.na(region_df$total_crop_area_ha)] <- 0

  # Score de vulnérabilité composite
  region_df$vulnerability_score <- with(region_df, mean_deficit * sqrt(total_crop_area_ha + 1))

  # Ranking
  region_df <- region_df[order(region_df$vulnerability_score, decreasing = TRUE), ]
  region_df$rank <- seq_len(nrow(region_df))

  rownames(region_df) <- NULL
  region_df
}
