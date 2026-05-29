#' Calculate pollination deficit
#' @param pollination_index SpatRaster
#' @param crop_needs SpatRaster or numeric threshold
#' @return SpatRaster
#' @export
calculate_pollination_deficit <- function(pollination_index, crop_needs = 0.5) {
  m <- matrix(c(0, crop_needs*0.5, 1, crop_needs*0.5, crop_needs*1.5, 2, crop_needs*1.5, 1, 3), ncol=3, byrow=TRUE)
  terra::classify(pollination_index, m)
}
