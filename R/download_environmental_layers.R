#' Download environmental layers
#'
#' Télécharge les données climatiques WorldClim et les couches landcover ESA
#' pour le Maroc via geodata.
#'
#' @return SpatRaster stack
#' @export
#' @examples
#' \dontrun{
#'   env <- download_environmental_layers()
#'   names(env)
#' }
download_environmental_layers <- function() {
  if (!requireNamespace("geodata", quietly = TRUE)) {
    stop(
      "Package 'geodata' is required. ",
      "Install with: install.packages('geodata')"
    )
  }

  tdir <- tempdir()

  message("Downloading WorldClim bioclim for Morocco...")
  wc <- geodata::worldclim_country(country = "Morocco", var = "bio", res = 5, path = tdir)

  message("Downloading elevation...")
  elevation <- geodata::elevation_30s(country = "Morocco", path = tdir)

  temp <- wc[[1]]
  prec <- wc[[12]]

  message("Downloading landcover layers...")
  lc_vars <- c("cropland", "trees", "grassland", "shrubs", "built", "water")

  lc_layers <- lapply(lc_vars, function(v) {
    message("  - ", v)
    r <- tryCatch(
      geodata::landcover(var = v, path = tdir),
      error = function(e) NULL
    )
    if (is.null(r)) {
      message("    (unavailable, using zero raster)")
      terra::rast(nrows = terra::nrow(temp), ncols = terra::ncol(temp),
                  xmin = terra::xmin(temp), xmax = terra::xmax(temp),
                  ymin = terra::ymin(temp), ymax = terra::ymax(temp),
                  crs = terra::crs(temp), vals = 0)
    } else {
      terra::resample(r, temp, method = "bilinear")
    }
  })

  elevation <- terra::resample(elevation, temp, method = "bilinear")

  env <- c(temp, prec, elevation, lc_layers[[1]], lc_layers[[2]],
           lc_layers[[3]], lc_layers[[4]], lc_layers[[5]], lc_layers[[6]])

  names(env) <- c(
    "temperature", "precipitation", "altitude",
    "cropland", "trees", "grassland", "shrubs", "built", "water"
  )

  message("Environmental stack ready: ", length(names(env)), " layers")
  env
}
