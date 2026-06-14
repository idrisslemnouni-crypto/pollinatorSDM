test_that("clean_occurrences removes NA coordinates", {
  occ <- data.frame(
    species   = c("Apis mellifera", "Bombus terrestris", "Apis mellifera"),
    longitude = c(-5.0, NA, -6.0),
    latitude  = c(33.5, 34.0, 33.0),
    stringsAsFactors = FALSE
  )
  env <- terra::rast(
    nrows = 20, ncols = 20,
    xmin = -9, xmax = -4,
    ymin = 31, ymax = 36,
    crs  = "EPSG:4326"
  )
  terra::values(env) <- cbind(
    bio1  = rnorm(400, 18, 4),
    bio12 = rnorm(400, 350, 80),
    ndvi  = runif(400, 0.1, 0.8)
  )
  names(env) <- c("bio1", "bio12", "ndvi")

  result <- clean_occurrences(occ, env)

  expect_type(result, "list")
  expect_true("data"   %in% names(result))
  expect_true("report" %in% names(result))
  expect_true(inherits(result$data, "sf"))
  expect_lt(nrow(result$data), nrow(occ))
})

test_that("clean_occurrences retourne un rapport de nettoyage", {
  occ <- data.frame(
    species   = c("Apis mellifera", "Apis mellifera"),
    longitude = c(-5.5, -5.5),
    latitude  = c(33.5, 33.5),
    stringsAsFactors = FALSE
  )
  env <- terra::rast(
    nrows = 20, ncols = 20,
    xmin = -9, xmax = -4,
    ymin = 31, ymax = 36,
    crs  = "EPSG:4326"
  )
  terra::values(env) <- cbind(
    bio1  = rnorm(400, 18, 4),
    bio12 = rnorm(400, 350, 80),
    ndvi  = runif(400, 0.1, 0.8)
  )
  names(env) <- c("bio1", "bio12", "ndvi")

  result <- clean_occurrences(occ, env)
  expect_true(is.list(result$report) || is.data.frame(result$report) ||
              is.character(result$report))
})
