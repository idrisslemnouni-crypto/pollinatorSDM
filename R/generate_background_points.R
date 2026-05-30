#' Generate background points
#'
#' Génère des pseudo-absences aléatoires en excluant un buffer autour des points
#' de présence, avec contrôle spatial (distance minimum entre background points).
#'
#' @param env_rasters SpatRaster
#' @param presence_sf sf object des présences
#' @param n_points integer, nombre de points (défaut 1000)
#' @param buffer_km numeric, buffer d'exclusion autour des présences en km (défaut 5)
#' @param min_dist_km numeric, distance minimum entre background points en km (défaut 10)
#' @return sf object
#' @export
generate_background_points <- function(env_rasters, presence_sf, n_points = 1000, buffer_km = 5, min_dist_km = 10) {
  # Buffer autour des présences pour exclusion
  pres_buff <- sf::st_buffer(presence_sf, dist = buffer_km * 1000)
  union_buff <- sf::st_union(pres_buff)

  # Masque raster inverse
  mask_raster <- env_rasters[[1]]
  terra::values(mask_raster) <- 1
  mask_vect <- terra::vect(union_buff)
  mask_vect <- terra::project(mask_vect, terra::crs(mask_raster))
  masked <- terra::mask(mask_raster, mask_vect, inverse = TRUE, updatevalue = NA)

  # Échantillonnage aléatoire sur zones libres
  pts <- terra::spatSample(masked, size = n_points * 3, method = "random", xy = TRUE, values = FALSE, na.rm = TRUE)
  pts <- pts[complete.cases(pts), ]

  if (nrow(pts) < n_points) {
    warning("Could not generate enough background points, returning ", nrow(pts))
    n_points <- nrow(pts)
  }

  # Contrôle spatial : distance minimum entre points
  keep <- rep(TRUE, nrow(pts))
  for (i in seq_len(nrow(pts))) {
    if (!keep[i]) next
    dists <- sqrt((pts[, 1] - pts[i, 1])^2 + (pts[, 2] - pts[i, 2])^2)
    dists_km <- dists * 111  # approx km
    too_close <- which(dists_km < min_dist_km & seq_len(nrow(pts)) > i)
    if (length(too_close) > 0) keep[too_close] <- FALSE
  }

  pts <- pts[keep, , drop = FALSE]
  if (nrow(pts) > n_points) pts <- pts[seq_len(n_points), ]

  sf::st_as_sf(as.data.frame(pts), coords = c("x", "y"), crs = terra::crs(env_rasters))
}
