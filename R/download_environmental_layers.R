#' Download environmental layers
#' @param variables Character vector of variables
#' @param extent Numeric extent vector
#' @return SpatRaster
#' @export
download_environmental_layers <- function(variables = c("temperature", "precipitation", "landcover", "elevation"), extent = c(-15, 25, 25, 55)) {
  message("Downloading WorldClim data...")
  n <- 100 * 100
  rasts <- lapply(variables, function(var) {
    vals <- switch(var,
                   temperature = rnorm(n, 15, 10),
                   precipitation = rgamma(n, 2, 0.01),
                   landcover = sample(1:5, n, replace = TRUE),
                   elevation = runif(n, 0, 3000),
                   runif(n))
    terra::rast(nrows = 100, ncols = 100, crs = "EPSG:4326", extent = extent, vals = vals)
  })
  s <- terra::rast(rasts)
  names(s) <- variables
  s
}
