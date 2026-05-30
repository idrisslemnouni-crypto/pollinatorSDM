#' Clean occurrence data
#'
#' Nettoie les données d'occurrence : supprime doublons, coordonnées nulles,
#' points marins (hors terre), rarefaction spatiale, et outliers géographiques.
#'
#' @param data data.frame avec colonnes decimalLongitude, decimalLatitude, species
#' @param env_rasters SpatRaster pour masque terrestre et rarefaction
#' @return list(data = sf object, report = data.frame)
#' @export
clean_occurrences <- function(data, env_rasters) {
  report <- data.frame(
    step = character(),
    n_records = integer(),
    stringsAsFactors = FALSE
  )
  report <- rbind(report, data.frame(step = "raw", n_records = nrow(data)))

  # Suppression doublons exacts
  data <- unique(data)
  report <- rbind(report, data.frame(step = "after_dedup", n_records = nrow(data)))

  # Suppression coordonnées nulles ou invalides
  data <- data[complete.cases(data$decimalLongitude, data$decimalLatitude), ]
  data <- data[data$decimalLongitude >= -180 & data$decimalLongitude <= 180, ]
  data <- data[data$decimalLatitude >= -90 & data$decimalLatitude <= 90, ]
  report <- rbind(report, data.frame(step = "after_coord_filter", n_records = nrow(data)))

  # Conversion sf
  pts <- sf::st_as_sf(data, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

  # Suppression points marins (hors raster terrestre)
  terra_pts <- terra::vect(pts)
  terra_pts <- terra::project(terra_pts, terra::crs(env_rasters))
  vals <- terra::extract(env_rasters[[1]], terra_pts, df = TRUE, ID = FALSE)
  pts <- pts[!is.na(vals[[1]]), ]
  report <- rbind(report, data.frame(step = "after_land_mask", n_records = nrow(pts)))

  # Rarefaction spatiale : 1 point par cellule raster
  terra_pts <- terra::vect(pts)
  terra_pts <- terra::project(terra_pts, terra::crs(env_rasters))
  cells <- terra::cellFromXY(env_rasters[[1]], terra::crds(terra_pts))
  pts$cell <- cells
  pts <- pts[!duplicated(pts$cell), ]
  pts$cell <- NULL
  report <- rbind(report, data.frame(step = "after_spatial_thinning", n_records = nrow(pts)))

  # Détection outliers : distance au centroïde par espèce
  outlier_idx <- integer()
  for (sp in unique(pts$species)) {
    sp_pts <- pts[pts$species == sp, ]
    if (nrow(sp_pts) < 5) next
    coords <- sf::st_coordinates(sp_pts)
    centroid <- apply(coords, 2, median)
    dists <- sqrt((coords[, 1] - centroid[1])^2 + (coords[, 2] - centroid[2])^2)
    thresh <- median(dists) + 3 * mad(dists)
    outlier_idx <- c(outlier_idx, which(pts$species == sp & dists > thresh))
  }
  if (length(outlier_idx) > 0) {
    pts <- pts[-outlier_idx, ]
  }
  report <- rbind(report, data.frame(step = "after_outlier_removal", n_records = nrow(pts)))

  list(data = pts, report = report)
}
