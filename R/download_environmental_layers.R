#' Download environmental layers
#' @return list of SpatRaster
#' @export
download_environmental_layers <- function() {
  if (requireNamespace("geodata", quietly = TRUE)) {
    message("Downloading WorldClim data for Morocco (this may take 1-2 minutes)...")

    tdir <- tempdir()

    # WorldClim Bioclim: BIO1 = mean temp, BIO12 = annual precipitation
    wc <- geodata::worldclim_country(country = "Morocco", var = "bio", res = 5, path = tdir)
    temp_raster <- wc[[1]]
    prec_raster <- wc[[12]]

    # Elevation
    alt_raster <- geodata::elevation_30s(country = "Morocco", path = tdir)

    # Landcover (tree cover fraction), resampled to same grid
    lc <- tryCatch({
      lcov <- geodata::landcover(var = "trees", path = tdir)
      terra::resample(lcov, temp_raster, method = "near")
    }, error = function(e) {
      message("Real landcover unavailable, using simulated fallback")
      terra::rast(nrows = terra::nrow(temp_raster),
                  ncols = terra::ncol(temp_raster),
                  xmin = terra::xmin(temp_raster),
                  xmax = terra::xmax(temp_raster),
                  ymin = terra::ymin(temp_raster),
                  ymax = terra::ymax(temp_raster),
                  crs = terra::crs(temp_raster),
                  vals = sample(1:5, terra::ncell(temp_raster), replace = TRUE))
    })

    names(temp_raster) <- "temperature"
    names(prec_raster) <- "precipitation"
    names(alt_raster) <- "altitude"
    names(lc) <- "landcover"

  } else {
    message("Package 'geodata' not installed. Using simulated data.")
    ext <- terra::ext(-10, 0, 28, 36)
    temp_raster <- terra::rast(nrows = 50, ncols = 50, extent = ext, crs = "EPSG:4326", vals = rnorm(2500, 18, 5))
    prec_raster <- terra::rast(nrows = 50, ncols = 50, extent = ext, crs = "EPSG:4326", vals = rgamma(2500, shape = 2, scale = 150))
    alt_raster <- terra::rast(nrows = 50, ncols = 50, extent = ext, crs = "EPSG:4326", vals = runif(2500, 0, 1500))
    lc <- terra::rast(nrows = 50, ncols = 50, extent = ext, crs = "EPSG:4326", vals = sample(1:5, 2500, replace = TRUE))
    names(temp_raster) <- "temperature"
    names(prec_raster) <- "precipitation"
    names(alt_raster) <- "altitude"
    names(lc) <- "landcover"
  }

  list(temp_raster = temp_raster, prec_raster = prec_raster, alt_raster = alt_raster, landcover = lc)
}
