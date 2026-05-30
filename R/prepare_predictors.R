#' Prepare predictors for SDM
#'
#' Extrait les valeurs raster, supprime variables corrélées (Pearson > 0.8),
#' calcule VIF simple, et retourne dataset prêt.
#'
#' @param occurrence_sf sf object d'occurrences (présence)
#' @param background_sf sf object de pseudo-absences
#' @param env_rasters SpatRaster stack
#' @return data.frame prêt pour SDM
#' @export
prepare_predictors <- function(occurrence_sf, background_sf, env_rasters) {
  # Extraction raster
  occ_vect <- terra::vect(occurrence_sf)
  occ_vect <- terra::project(occ_vect, terra::crs(env_rasters))
  occ_vals <- terra::extract(env_rasters, occ_vect, df = TRUE, ID = FALSE)
  occ_vals$occurrence <- 1

  bg_vect <- terra::vect(background_sf)
  bg_vect <- terra::project(bg_vect, terra::crs(env_rasters))
  bg_vals <- terra::extract(env_rasters, bg_vect, df = TRUE, ID = FALSE)
  bg_vals$occurrence <- 0

  combined <- rbind(occ_vals, bg_vals)
  combined <- combined[complete.cases(combined), ]

  # Sélection variables : corrélation Pearson
  pred_vars <- setdiff(names(combined), "occurrence")
  cor_mat <- cor(combined[, pred_vars], use = "pairwise.complete.obs")

  # Supprimer variables corrélées > 0.8
  to_remove <- character()
  for (i in seq_len(nrow(cor_mat))) {
    for (j in seq_len(ncol(cor_mat))) {
      if (i < j && abs(cor_mat[i, j]) > 0.8) {
        to_remove <- c(to_remove, colnames(cor_mat)[j])
      }
    }
  }
  to_remove <- unique(to_remove)
  if (length(to_remove) > 0) {
    combined <- combined[, setdiff(names(combined), to_remove), drop = FALSE]
  }

  # VIF simple (approximation via R² de régression linéaire)
  pred_vars <- setdiff(names(combined), "occurrence")
  vif_vals <- sapply(pred_vars, function(v) {
    others <- setdiff(pred_vars, v)
    if (length(others) < 2) return(1)
    f <- as.formula(paste(v, "~", paste(others, collapse = "+")))
    r2 <- summary(lm(f, data = combined))$r.squared
    1 / (1 - r2)
  })

  high_vif <- names(vif_vals)[vif_vals > 10]
  if (length(high_vif) > 0) {
    combined <- combined[, setdiff(names(combined), high_vif), drop = FALSE]
  }

  combined
}
