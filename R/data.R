#' Pollinator occurrence example data
#'
#' A dataset of simulated pollinator occurrence records for three species
#' across a study region in Morocco.
#'
#' @format A data frame with 30 rows and 4 variables:
#' \describe{
#'   \item{species}{Character. Scientific name of the pollinator species.
#'     Values: "Apis mellifera", "Bombus terrestris", "Bombus lapidarius".}
#'   \item{decimalLongitude}{Numeric. Longitude in decimal degrees (WGS84).}
#'   \item{decimalLatitude}{Numeric. Latitude in decimal degrees (WGS84).}
#'   \item{year}{Integer. Year of observation.}
#' }
#' @source Simulated data for package illustration purposes.
#' @examples
#' data(pollinator_occurrences)
#' head(pollinator_occurrences)
"pollinator_occurrences"

#' Crop pollination dependency data
#'
#' A dataset of crop species and their dependence on insect pollination,
#' based on FAO and Klein et al. (2007) classifications.
#'
#' @format A data frame with 5 rows and 3 variables:
#' \describe{
#'   \item{crop}{Character. Common name of the crop.}
#'   \item{dependency}{Numeric. Pollination dependency factor (0 to 1).
#'     0 = no dependence, 1 = full dependence.}
#'   \item{notes}{Character. Brief description of the dependency level.}
#' }
#' @source Klein, A.M. et al. (2007). Importance of pollinators in changing
#'   landscapes for world crops. Proceedings of the Royal Society B, 274(1608),
#'   303-313.
#' @examples
#' data(crop_dependencies)
#' head(crop_dependencies)
"crop_dependencies"
