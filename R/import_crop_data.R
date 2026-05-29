#' Import crop dependency data
#' @param source Character source type
#' @return data.frame
#' @export
import_crop_data <- function(source = "example") {
  data.frame(
    crop = c("amandier", "pommier", "tournesol", "colza", "tomate"),
    pollination_dependence = c("elevee", "elevee", "moderee", "moderee", "faible"),
    dependence_score = c(0.9, 0.8, 0.6, 0.5, 0.3),
    surface_ha = c(100, 200, 150, 300, 80)
  )
}
