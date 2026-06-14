#' @importFrom stats na.omit predict rgamma rnorm runif cor complete.cases
NULL

#' Verifier si un objet est un raster SpatRaster
#'
#' @param x objet a tester
#' @return logical TRUE si x est un SpatRaster
#' @keywords internal
is_raster <- function(x) inherits(x, "SpatRaster")

#' Verifier si un objet est un objet sf
#'
#' @param x objet a tester
#' @return logical TRUE si x est un sf
#' @keywords internal
is_sf <- function(x) inherits(x, "sf")

#' Calculer le pourcentage de NA dans un vecteur
#'
#' @param x vecteur numerique
#' @return numeric proportion de NA entre 0 et 1
#' @keywords internal
pct_na <- function(x) mean(is.na(x))

#' Normaliser un vecteur entre 0 et 1
#'
#' @param x vecteur numerique
#' @return vecteur normalise
#' @keywords internal
normalize_0_1 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (diff(rng) == 0) return(rep(0, length(x)))
  (x - rng[1]) / diff(rng)
}

#' Message de log horodate
#'
#' @param ... elements a afficher
#' @keywords internal
log_msg <- function(...) {
  message(format(Sys.time(), "[%H:%M:%S]"), " ", ...)
}
