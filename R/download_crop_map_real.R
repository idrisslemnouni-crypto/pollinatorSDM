#' Download real crop map from ESA WorldCover
#'
#' Utilise le raster cropland d'ESA WorldCover (déjà téléchargé dans env)
#' pour créer une carte vectorielle réelle des zones cultivées au Maroc.
#' Les cultures sont assignées par zone climatique.
#'
#' @param env_rasters SpatRaster stack avec couche "cropland"
#' @return sf object avec polygones de cultures réels
#' @export
download_crop_map_real <- function(env_rasters) {
  if (!requireNamespace("terra", quietly = TRUE)) stop("terra required")
  if (!requireNamespace("sf", quietly = TRUE)) stop("sf required")

  # Extraire la couche cropland
  if (!"cropland" %in% names(env_rasters)) {
    stop("Layer 'cropland' not found in environmental rasters.")
  }

  cropland <- env_rasters[["cropland"]]

  # Seuiller : zones avec > 20% de cultures
  agri_mask <- cropland > 0.2

  # Convertir en entier pour clump/patches
  agri_int <- as.numeric(agri_mask)

  # Regrouper les zones connectées en polygones
  message("Vectorizing cropland raster (this may take 1-2 minutes)...")
  agri_poly <- terra::as.polygons(terra::patches(agri_int, zeroAsNA = TRUE), dissolve = TRUE)

  # Convertir en sf
  agri_sf <- sf::st_as_sf(agri_poly)

  # Simplifier pour réduire la complexité
  agri_sf <- sf::st_simplify(agri_sf, dTolerance = 0.01)

  # Filtrer les très petits polygones (< 1 hectare)
  agri_sf$area_ha <- as.numeric(sf::st_area(agri_sf)) / 10000
  agri_sf <- agri_sf[agri_sf$area_ha > 1, ]

  if (nrow(agri_sf) == 0) {
    stop("No agricultural polygons found. Check cropland threshold.")
  }

  # Stratification climatique pour assigner les cultures
  # Extraire température et précipitation au centroïde de chaque polygone
  cents <- terra::vect(sf::st_centroid(agri_sf))
  clim <- terra::extract(env_rasters, cents, df = TRUE, ID = FALSE)

  # Assigner culture par niche climatique
  # Amandier : frais, altitude modérée (T < 16°C, prec > 250mm)
  # Pommier : frais (T 14-18°C, prec > 300mm)
  # Colza : tempéré (T 16-20°C)
  # Tournesol : chaud, sec (T > 18°C, prec < 400mm)
  # Tomate : chaud (T > 20°C)

  agri_sf$crop_type <- NA_character_

  for (i in seq_len(nrow(agri_sf))) {
    t <- clim$temperature[i]
    p <- clim$precipitation[i]
    a <- clim$altitude[i]

    if (is.na(t) || is.na(p)) next

    if (t < 16 & p > 300) {
      agri_sf$crop_type[i] <- "almond"
    } else if (t >= 16 & t < 19 & p > 250) {
      agri_sf$crop_type[i] <- "apple"
    } else if (t >= 16 & t < 20) {
      agri_sf$crop_type[i] <- "canola"
    } else if (t >= 18 & p < 400) {
      agri_sf$crop_type[i] <- "sunflower"
    } else {
      agri_sf$crop_type[i] <- "tomato"
    }
  }

  # Enlever les non-assignés
  agri_sf <- agri_sf[!is.na(agri_sf$crop_type), ]

  message("Real crop map created: ", nrow(agri_sf), " polygons, ",
          round(sum(agri_sf$area_ha), 1), " total hectares")

  agri_sf
}
