#' Generate management recommendations
#'
#' Génère recommandations basées sur déficit de pollinisation et paysage.
#'
#' @param suitability_raster SpatRaster de suitability pollinisateurs
#' @param deficit_raster SpatRaster du déficit
#' @param landscape_analysis list de analyze_landscape()
#' @return data.frame des recommandations
#' @export
generate_recommendations <- function(suitability_raster, deficit_raster, landscape_analysis) {
  deficit_mean <- as.numeric(mean(terra::values(deficit_raster), na.rm = TRUE))
  suitability_mean <- as.numeric(mean(terra::values(suitability_raster), na.rm = TRUE))
  patch_density <- as.numeric(landscape_analysis$patch_density)
  mean_patch_area <- as.numeric(landscape_analysis$mean_patch_area)
  total_edge <- as.numeric(landscape_analysis$total_edge)
  landscape_division <- as.numeric(landscape_analysis$landscape_metrics["landscape division index"])

  if (length(landscape_division) == 0 || is.na(landscape_division)) landscape_division <- 0
  if (length(patch_density) == 0 || is.na(patch_density)) patch_density <- 0
  if (length(mean_patch_area) == 0 || is.na(mean_patch_area)) mean_patch_area <- 0
  if (length(total_edge) == 0 || is.na(total_edge)) total_edge <- 0

  recommendations <- data.frame(
    category = character(),
    recommendation = character(),
    priority = character(),
    details = character(),
    stringsAsFactors = FALSE
  )

  if (isTRUE(deficit_mean > 0.1)) {
    recommendations <- rbind(recommendations, data.frame(
      category = "urgent",
      recommendation = "Creation of pollinator refuge zones",
      priority = "high",
      details = paste0("Average deficit of ", round(deficit_mean, 3), " detected. Priority planting in agricultural areas.")
    ))

    recommendations <- rbind(recommendations, data.frame(
      category = "landscape",
      recommendation = "Habitat connectivity restoration",
      priority = "high",
      details = paste0("Landscape division index: ", round(landscape_division, 2), ". Establish pollinator corridors.")
    ))

    recommendations <- rbind(recommendations, data.frame(
      category = "management",
      recommendation = "Agroecological transition",
      priority = "high",
      details = "Intensive agriculture with high pollination deficit. Reduce pesticides and diversify crops."
    ))
  } else if (isTRUE(deficit_mean > 0.05)) {
    recommendations <- rbind(recommendations, data.frame(
      category = "moderate",
      recommendation = "Maintenance of existing habitats",
      priority = "medium",
      details = paste0("Moderate deficit of ", round(deficit_mean, 3), ". Maintain and protect natural habitats.")
    ))
  }

  if (isTRUE(suitability_mean < 0.3)) {
    recommendations <- rbind(recommendations, data.frame(
      category = "restoration",
      recommendation = "Habitat quality improvement",
      priority = "high",
      details = "Very low pollinator suitability. Plant native melliferous species."
    ))
  }

  if (isTRUE(patch_density < 0.001)) {
    recommendations <- rbind(recommendations, data.frame(
      category = "landscape",
      recommendation = "Fragmentation mitigation",
      priority = "medium",
      details = paste0("Very low patch density (", format(patch_density, scientific = TRUE), "). Reduce isolation.")
    ))
  }

  if (isTRUE(mean_patch_area < 100)) {
    recommendations <- rbind(recommendations, data.frame(
      category = "landscape",
      recommendation = "Buffer zones around small patches",
      priority = "medium",
      details = paste0("Small average patches (", round(mean_patch_area, 1), " ha). Create protective buffer zones.")
    ))
  }

  if (isTRUE(total_edge > 100000)) {
    recommendations <- rbind(recommendations, data.frame(
      category = "edge_management",
      recommendation = "Edge effect optimization",
      priority = "medium",
      details = paste0("High total edge (", round(total_edge / 1000, 1), " km). Plant hedgerows to maximize edge habitats.")
    ))
  }

  if (nrow(recommendations) == 0) {
    recommendations <- rbind(recommendations, data.frame(
      category = "monitoring",
      recommendation = "Continue monitoring",
      priority = "low",
      details = "Current situation acceptable. Maintain regular monitoring."
    ))
  }

  recommendations
}
