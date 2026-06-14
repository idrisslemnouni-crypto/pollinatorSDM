#' Summarise Pollination Deficit Risk by Region
#'
#' Aggregates cell-level pollination deficit values into spatial grid regions
#' and computes a vulnerability score for each region based on deficit
#' magnitude and crop area.
#'
#' @param deficit_raster A \code{SpatRaster} of pollination deficit values
#'   (0-1 range, output of \code{\link{calculate_pollination_deficit}}).
#' @param crop_map An \code{sf} object with an \code{area_ha} column
#'   representing crop fields in the study region.
#' @param grid_size Numeric. Size of the aggregation grid cells in
#'   coordinate units (default \code{1} degree).
#'
#' @return A \code{data.frame} with one row per region, containing:
#'   \describe{
#'     \item{region_id}{Integer. Unique region identifier.}
#'     \item{mean_deficit}{Numeric. Mean deficit across cells in the region.}
#'     \item{max_deficit}{Numeric. Maximum deficit in the region.}
#'     \item{n_cells}{Integer. Number of raster cells in the region.}
#'     \item{total_crop_area_ha}{Numeric. Total crop area (ha) in the region.}
#'     \item{vulnerability_score}{Numeric. Combined risk score
#'       (\code{mean_deficit * sqrt(total_crop_area_ha + 1)}).}
#'     \item{rank}{Integer. Rank from highest to lowest vulnerability.}
#'   }
#'   Rows are sorted by decreasing \code{vulnerability_score}.
#'
#' @importFrom terra as.points crds ext
#' @importFrom sf st_coordinates st_centroid st_drop_geometry
#' @importFrom stats aggregate
#' @export
#'
#' @examples
#' \dontrun{
#' # requires a deficit raster and an sf crop map with area_ha column
#' risk <- summarize_risk_by_region(poll_deficit, crop_map)
#' print(risk)
#' }
summarize_risk_by_region <- function(deficit_raster, crop_map, grid_size = 1) {
  if (!requireNamespace("sf", quietly = TRUE)) stop("sf required")

  pts <- terra::as.points(deficit_raster, na.rm = TRUE)
  pts_df <- as.data.frame(pts)
  if (nrow(pts_df) == 0) {
    return(data.frame(
      region_id = integer(0),
      mean_deficit = numeric(0),
      max_deficit = numeric(0),
      n_cells = integer(0),
      total_crop_area_ha = numeric(0),
      vulnerability_score = numeric(0),
      rank = integer(0)
    ))
  }

  names(pts_df)[1] <- "deficit"
  coords <- terra::crds(pts)
  pts_df$x <- coords[, 1]
  pts_df$y <- coords[, 2]

  ext <- terra::ext(deficit_raster)
  pts_df$zone_x <- floor((pts_df$x - ext[1]) / grid_size)
  pts_df$zone_y <- floor((pts_df$y - ext[3]) / grid_size)
  pts_df$region_key <- paste(pts_df$zone_x, pts_df$zone_y, sep = "_")
  pts_df$region_id <- as.numeric(factor(pts_df$region_key))

  region_stats <- stats::aggregate(
    deficit ~ region_id,
    data = pts_df,
    FUN = function(x) c(mean = mean(x, na.rm = TRUE),
                        max  = max(x, na.rm = TRUE),
                        n    = length(x))
  )
  if (nrow(region_stats) == 0) {
    return(data.frame(
      region_id = integer(0),
      mean_deficit = numeric(0),
      max_deficit = numeric(0),
      n_cells = integer(0),
      total_crop_area_ha = numeric(0),
      vulnerability_score = numeric(0),
      rank = integer(0)
    ))
  }

  region_mat <- do.call(rbind, region_stats$deficit)
  region_df <- data.frame(
    region_id    = region_stats$region_id,
    mean_deficit = region_mat[, 1],
    max_deficit  = region_mat[, 2],
    n_cells      = as.integer(region_mat[, 3])
  )

  cent <- sf::st_coordinates(sf::st_centroid(crop_map))
  crop_map$centroid_lon <- cent[, 1]
  crop_map$centroid_lat <- cent[, 2]
  zx <- floor((crop_map$centroid_lon - ext[1]) / grid_size)
  zy <- floor((crop_map$centroid_lat - ext[3]) / grid_size)
  crop_map$region_key <- paste(zx, zy, sep = "_")

  key_to_id <- unique(pts_df[, c("region_key", "region_id")])
  crop_map <- merge(crop_map, key_to_id, by = "region_key", all.x = TRUE)
  crop_map_valid <- crop_map[!is.na(crop_map$region_id), ]

  if (nrow(crop_map_valid) == 0) {
    region_df$total_crop_area_ha <- 0
  } else {
    area_by_region <- stats::aggregate(
      area_ha ~ region_id,
      data = sf::st_drop_geometry(crop_map_valid),
      FUN = sum,
      na.rm = TRUE
    )
    names(area_by_region) <- c("region_id", "total_crop_area_ha")
    region_df <- merge(region_df, area_by_region, by = "region_id", all.x = TRUE)
    region_df$total_crop_area_ha[is.na(region_df$total_crop_area_ha)] <- 0
  }

  region_df$vulnerability_score <- with(
    region_df,
    mean_deficit * sqrt(total_crop_area_ha + 1)
  )
  region_df <- region_df[order(region_df$vulnerability_score, decreasing = TRUE), ]
  region_df$rank <- seq_len(nrow(region_df))
  rownames(region_df) <- NULL
  region_df
}
