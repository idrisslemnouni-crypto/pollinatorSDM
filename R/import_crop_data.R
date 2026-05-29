#' Import crop pollination data
#' @param file_path Optional path to CSV file
#' @return data.frame with crop dependencies
#' @export
import_crop_data <- function(file_path = NULL) {
  if (!is.null(file_path) && file.exists(file_path)) {
    read.csv(file_path, stringsAsFactors = FALSE)
  } else {
    data("crop_dependencies", package = "pollinatorSDM", envir = environment())
    crop_dependencies
  }
}
