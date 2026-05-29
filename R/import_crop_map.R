#' Import crop map
#'
#' Lit un fichier vectoriel des cultures (GeoPackage, Shapefile, etc.)
#' et vérifie la présence de la colonne obligatoire crop_type.
#'
#' @param path Chemin vers le fichier vectoriel
#' @return sf object
#' @export
#' @examples
#' \dontrun{
#'   crop_map <- import_crop_map("data-raw/crop_map.gpkg")
#' }
import_crop_map <- function(path) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Package 'sf' is required.")
  }

  if (!file.exists(path)) {
    stop("File not found: ", path)
  }

  crops_sf <- sf::st_read(path, quiet = TRUE)

  if (!"crop_type" %in% names(crops_sf)) {
    stop("Column 'crop_type' is required in the crop map.")
  }

  valid_crops <- c("almond", "apple", "sunflower", "canola", "tomato")
  crops_sf <- crops_sf[crops_sf$crop_type %in% valid_crops, ]

  if (nrow(crops_sf) == 0) {
    stop("No valid crops found. Expected: ", paste(valid_crops, collapse = ", "))
  }

  crops_sf
}
