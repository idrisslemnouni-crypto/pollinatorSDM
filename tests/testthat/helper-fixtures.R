make_raster <- function(nrows = 10, ncols = 10, n_layers = 3) {
  r <- terra::rast(
    nrows = nrows, ncols = ncols, nlyrs = n_layers,
    xmin = -9, xmax = -4,
    ymin = 31, ymax = 36,
    crs = "EPSG:4326"
  )
  vals <- matrix(runif(nrows * ncols * n_layers), ncol = n_layers)
  terra::values(r) <- vals
  names(r) <- paste0("var", seq_len(n_layers))
  r
}

make_occurrences <- function(n = 10) {
  data.frame(
    decimalLongitude = runif(n, -8.5, -4.5),
    decimalLatitude  = runif(n, 31.5, 35.5),
    species          = sample(c("Apis mellifera", "Bombus terrestris"),
                              n, replace = TRUE),
    stringsAsFactors = FALSE
  )
}

make_train_df <- function(n_per_class = 25, seed = 99) {
  set.seed(seed)
  data.frame(
    occurrence = factor(rep(c(0, 1), each = n_per_class)),
    var1 = c(rnorm(n_per_class, 10, 2), rnorm(n_per_class, 15, 2)),
    var2 = c(rnorm(n_per_class,  5, 1), rnorm(n_per_class,  8, 1))
  )
}

