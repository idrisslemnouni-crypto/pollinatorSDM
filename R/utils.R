#' Pipe operator
#'
#' Re-exports the magrittr pipe operator for use within the package.
#'
#' @importFrom dplyr %>%
#' @name %>%
#' @rdname pipe
#' @export
NULL

#' Check that a SpatRaster has named layers
#'
#' @param raster A \code{SpatRaster} object.
#' @param required_names Character vector of required layer names.
#' @return Invisible \code{TRUE} if all layers are present; stops otherwise.
#' @keywords internal
check_raster_layers <- function(raster, required_names) {
  missing_layers <- setdiff(required_names, names(raster))
  if (length(missing_layers) > 0) {
    stop("Missing raster layers: ", paste(missing_layers, collapse = ", "))
  }
  invisible(TRUE)
}

#' Normalise a numeric vector to [0, 1]
#'
#' @param x Numeric vector.
#' @return Numeric vector scaled between 0 and 1.
#' @keywords internal
normalise_01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (diff(rng) == 0) return(rep(0, length(x)))
  (x - rng[1]) / diff(rng)
}
