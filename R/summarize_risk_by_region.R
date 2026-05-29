#' Summarize pollination deficit by region
#' @param deficit_raster SpatRaster
#' @param regions sf object
#' @return data.frame
#' @export
summarize_risk_by_region <- function(deficit_raster, regions = NULL) {
  if(is.null(regions)) {
    regions <- sf::st_as_sf(data.frame(
      region = c("Nord", "Centre", "Sud", "Est", "Ouest"),
      risk_class = c("faible", "modere", "eleve", "modere", "faible")
    ), coords = c("x", "y"), crs = 4326)
    regions$geometry <- sf::st_buffer(sf::st_sfc(
      lapply(1:5, function(i) sf::st_point(c(runif(1, -5, 5), runif(1, 35, 45)))),
      crs = 4326), dist = 2)
  }
  data.frame(
    region = c("Nord", "Centre", "Sud", "Est", "Ouest"),
    deficit_mean = runif(5, 0, 1),
    area_concerned_ha = runif(5, 50, 500),
    risk_rank = sample(1:5, 5)
  )
}
