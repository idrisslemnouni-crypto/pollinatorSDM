#' Generate recommendations
#'
#' Génère des recommandations agroécologiques basées sur la suitability,
#' le déficit de pollinisation et la fragmentation des habitats.
#'
#' @param prediction_raster SpatRaster, suitability des pollinisateurs
#' @param deficit_raster SpatRaster, déficit de pollinisation
#' @param landscape list, résultats de analyze_landscape()
#' @return data.frame de recommandations
#' @export
generate_recommendations <- function(prediction_raster, deficit_raster, landscape) {
  # Statistiques sur le déficit
  deficit_mean <- terra::global(deficit_raster, "mean", na.rm = TRUE)[1, 1]
  deficit_max <- terra::global(deficit_raster, "max", na.rm = TRUE)[1, 1]

  # Statistiques sur la suitability
  suit_mean <- terra::global(prediction_raster, "mean", na.rm = TRUE)[1, 1]

  # Nombre de patches
  n_patches <- landscape$n_patches

  # Recommandations textuelles
  recommendations <- data.frame(
    priority = character(),
    action = character(),
    target_zone = character(),
    stringsAsFactors = FALSE
  )

  # Recommandation 1 : zones à fort déficit
  if (deficit_mean > 0.1) {
    recommendations <- rbind(recommendations, data.frame(
      priority = "HIGH",
      action = "Install bee hotels and flower strips in high deficit zones",
      target_zone = "Agricultural areas with deficit > 0.1",
      stringsAsFactors = FALSE
    ))
  }

  # Recommandation 2 : fragmentation
  if (n_patches > 50) {
    recommendations <- rbind(recommendations, data.frame(
      priority = "MEDIUM",
      action = "Create habitat corridors between fragmented patches",
      target_zone = paste0("Connect ", n_patches, " habitat patches"),
      stringsAsFactors = FALSE
    ))
  }

  # Recommandation 3 : suitability faible
  if (suit_mean < 0.3) {
    recommendations <- rbind(recommendations, data.frame(
      priority = "HIGH",
      action = "Restore semi-natural habitats and reduce pesticide use",
      target_zone = "Low suitability zones",
      stringsAsFactors = FALSE
    ))
  }

  # Recommandation 4 : gestion générale
  recommendations <- rbind(recommendations, data.frame(
    priority = "MEDIUM",
    action = "Diversify crop rotation with pollinator-friendly plants",
    target_zone = "All agricultural zones",
    stringsAsFactors = FALSE
  ))

  recommendations
}
