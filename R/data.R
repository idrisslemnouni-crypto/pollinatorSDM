#' Pollinator occurrence example data
#'
#' A dataset of simulated pollinator occurrence records for three species
#' across a study region in Morocco (WGS84, GBIF-compatible format).
#'
#' @format A data frame with 30 rows and 4 variables:
#' \describe{
#'   \item{species}{Character. Scientific name of the pollinator species.
#'     Values: \code{"Apis mellifera"}, \code{"Bombus terrestris"},
#'     \code{"Bombus lapidarius"}.}
#'   \item{decimalLongitude}{Numeric. Longitude in decimal degrees (WGS84),
#'     ranging from approximately -9 to -4.}
#'   \item{decimalLatitude}{Numeric. Latitude in decimal degrees (WGS84),
#'     ranging from approximately 31 to 36.}
#'   \item{year}{Integer. Year of observation (2015--2022).}
#' }
#' @source Simulated data for package illustration purposes.
#'   Coordinate range corresponds to Morocco (central region).
#' @seealso \code{\link{download_pollinator_data}} to download real GBIF records.
#' @examples
#' data(pollinator_occurrences)
#' head(pollinator_occurrences)
#' table(pollinator_occurrences$species)
"pollinator_occurrences"

#' Crop pollination dependency data
#'
#' A dataset of crop species and their dependence on insect pollination,
#' for package illustration. The stored values have not been independently
#' verified against the cited literature and are not agronomic prescriptions.
#'
#' @format A data frame with four variables:
#' \describe{
#'   \item{crop}{Character. Common name of the crop.}
#'   \item{dependence_pollination}{Numeric. Illustrative dependency factor from 0 to 1.
#'     0 = no insect pollination dependence, 1 = fully dependent.}
#'   \item{family}{Character. Botanical family.}
#'   \item{type}{Character. Crop category.}
#' }
#' @source Klein, A.M., Vaissiere, B.E., Cane, J.H., Steffan-Dewenter, I.,
#'   Cunningham, S.A., Kremen, C. and Tscharntke, T. (2007). Importance of
#'   pollinators in changing landscapes for world crops.
#'   \emph{Proceedings of the Royal Society B}, 274(1608), 303--313.
#'   \doi{10.1098/rspb.2006.3721}
#' @seealso \code{\link{calculate_pollination_index}},
#'   \code{\link{calculate_pollination_deficit}}
#' @examples
#' data(crop_dependencies)
#' print(crop_dependencies)
#' barplot(crop_dependencies$dependence_pollination,
#'         names.arg = crop_dependencies$crop,
#'         main = "Pollination dependency by crop",
#'         ylab = "Dependency factor",
#'         col  = "steelblue")
"crop_dependencies"
