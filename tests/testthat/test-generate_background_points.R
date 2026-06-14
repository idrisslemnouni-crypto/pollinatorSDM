test_that("generate_background_points retourne un objet sf", {
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

  presence <- data.frame(longitude = c(-5.5, -6.0), latitude = c(33.5, 34.0))
  presence_sf <- sf::st_as_sf(presence, coords = c("longitude","latitude"),
                               crs = 4326)

  bg <- generate_background_points(env, presence_sf = presence_sf, n_points = 50)

  expect_true(inherits(bg, "sf"))
  expect_lte(nrow(bg), 50)
  expect_gt(nrow(bg), 0)
})

test_that("generate_background_points respecte le nombre de points demandes", {
  env <- terra::rast(
    nrows = 30, ncols = 30,
    xmin = -9, xmax = -4,
    ymin = 31, ymax = 36,
    crs  = "EPSG:4326"
  )
  terra::values(env) <- cbind(
    bio1  = rnorm(900, 18, 4),
    bio12 = rnorm(900, 350, 80),
    ndvi  = runif(900, 0.1, 0.8)
  )
  names(env) <- c("bio1", "bio12", "ndvi")

  presence_sf <- sf::st_as_sf(
    data.frame(longitude = -5.5, latitude = 33.5),
    coords = c("longitude","latitude"), crs = 4326
  )

  bg <- generate_background_points(env, presence_sf = presence_sf, n_points = 80)
  expect_lte(nrow(bg), 80)
})
