#' Generate management recommendations
#'
#' Generates agro-ecological management recommendations based on pollination
#' deficit severity and landscape fragmentation metrics.
#'
#' @param suitability_raster A \code{SpatRaster} of pollinator suitability (0-1).
#' @param deficit_raster A \code{SpatRaster} of pollination deficit values.
#'   If it has two layers (output of \code{\link{calculate_pollination_deficit}}),
#'   the first layer (continuous deficit) is used.
#' @param landscape_analysis A named \code{list} as returned by
#'   \code{\link{analyze_landscape}}.
#' @return A \code{data.frame} with columns \code{category},
#'   \code{recommendation}, \code{priority}, and \code{details}.
#' @export
#' @examples
#' \dontrun{
#'   reco <- generate_recommendations(pred_raster, deficit, landscape_stats)
#'   print(reco)
#' }
generate_recommendations <- function(suitability_raster,
                                     deficit_raster,
                                     landscape_analysis) {
  # Use first layer if multi-layer deficit raster
  if (terra::nlyr(deficit_raster) > 1) {
    deficit_raster <- deficit_raster[[1]]
  }

  deficit_mean     <- as.numeric(terra::global(deficit_raster,     "mean", na.rm = TRUE)[1, 1])
  suitability_mean <- as.numeric(terra::global(suitability_raster, "mean", na.rm = TRUE)[1, 1])

  # Safely extract landscape metrics
  n_patches      <- as.numeric(landscape_analysis$n_patches       %||% 0)
  mean_patch_size <- as.numeric(landscape_analysis$mean_patch_size %||% 0)
  total_habitat  <- as.numeric(landscape_analysis$total_habitat_area %||% 0)

  if (is.na(n_patches))       n_patches       <- 0
  if (is.na(mean_patch_size)) mean_patch_size  <- 0
  if (is.na(total_habitat))   total_habitat    <- 0

  recommendations <- data.frame(
    category       = character(),
    recommendation = character(),
    priority       = character(),
    details        = character(),
    stringsAsFactors = FALSE
  )

  # ── High deficit ────────────────────────────────────────────────────────────
  if (isTRUE(deficit_mean > 0.1)) {
    recommendations <- rbind(recommendations, data.frame(
      category       = "urgent",
      recommendation = "Creation of pollinator refuge zones",
      priority       = "high",
      details        = paste0(
        "Average deficit of ", round(deficit_mean, 3),
        " detected. Priority planting in agricultural areas."
      ),
      stringsAsFactors = FALSE
    ))
    recommendations <- rbind(recommendations, data.frame(
      category       = "landscape",
      recommendation = "Habitat connectivity restoration",
      priority       = "high",
      details        = paste0(
        "Establish pollinator corridors to reduce habitat isolation."
      ),
      stringsAsFactors = FALSE
    ))
    recommendations <- rbind(recommendations, data.frame(
      category       = "management",
      recommendation = "Agroecological transition",
      priority       = "high",
      details        = paste0(
        "High pollination deficit detected. Reduce pesticide use and diversify crops."
      ),
      stringsAsFactors = FALSE
    ))
  } else if (isTRUE(deficit_mean > 0.05)) {
    recommendations <- rbind(recommendations, data.frame(
      category       = "moderate",
      recommendation = "Maintenance of existing habitats",
      priority       = "medium",
      details        = paste0(
        "Moderate deficit of ", round(deficit_mean, 3),
        ". Maintain and protect existing natural habitats."
      ),
      stringsAsFactors = FALSE
    ))
  }

  # ── Low suitability ─────────────────────────────────────────────────────────
  if (isTRUE(suitability_mean < 0.3)) {
    recommendations <- rbind(recommendations, data.frame(
      category       = "restoration",
      recommendation = "Habitat quality improvement",
      priority       = "high",
      details        = "Very low pollinator suitability. Plant native melliferous species.",
      stringsAsFactors = FALSE
    ))
  }

  # ── Fragmentation ───────────────────────────────────────────────────────────
  if (isTRUE(n_patches > 50)) {
    recommendations <- rbind(recommendations, data.frame(
      category       = "landscape",
      recommendation = "Fragmentation mitigation",
      priority       = "medium",
      details        = paste0(
        n_patches, " habitat patches detected. Reduce isolation by creating corridors."
      ),
      stringsAsFactors = FALSE
    ))
  }

  if (isTRUE(mean_patch_size < 100)) {
    recommendations <- rbind(recommendations, data.frame(
      category       = "landscape",
      recommendation = "Buffer zones around small habitat patches",
      priority       = "medium",
      details        = paste0(
        "Average patch size: ", round(mean_patch_size, 1),
        " ha. Create protective buffer zones."
      ),
      stringsAsFactors = FALSE
    ))
  }

  # ── Fallback ─────────────────────────────────────────────────────────────────
  if (nrow(recommendations) == 0) {
    recommendations <- rbind(recommendations, data.frame(
      category       = "monitoring",
      recommendation = "Continue regular monitoring",
      priority       = "low",
      details        = "Current situation is acceptable. Maintain regular monitoring.",
      stringsAsFactors = FALSE
    ))
  }

  recommendations
}

# Internal null-coalescing operator
`%||%` <- function(x, y) if (!is.null(x)) x else y
