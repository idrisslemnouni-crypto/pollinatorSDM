#' Download pollinator occurrence data from GBIF
#'
#' Télécharge les occurrences réelles des trois pollinisateurs étudiés
#' pour le Maroc via l'API GBIF.
#'
#' @return data.frame avec colonnes species, longitude, latitude, year, basisOfRecord
#' @export
#' @examples
#' \dontrun{
#'   poll_data <- download_pollinator_data()
#'   head(poll_data)
#' }
download_pollinator_data <- function() {
  species <- c("Apis mellifera", "Bombus terrestris", "Bombus lapidarius")

  if (!requireNamespace("rgbif", quietly = TRUE)) {
    stop(
      "Package 'rgbif' is required for real GBIF download. ",
      "Install with: install.packages('rgbif')"
    )
  }

  all_data <- lapply(species, function(sp) {
    message("Downloading GBIF data for: ", sp)

    res <- rgbif::occ_search(
      scientificName = sp,
      country = "MA",
      hasCoordinate = TRUE,
      hasGeospatialIssue = FALSE,
      basisOfRecord = "HUMAN_OBSERVATION;OBSERVATION;PRESERVED_SPECIMEN",
      coordinateUncertaintyInMeters = "0,5000",
      limit = 500
    )

    df <- res$data

    if (is.null(df) || nrow(df) == 0) {
      message("  No records found for ", sp)
      return(NULL)
    }

    keep <- c("species", "decimalLongitude", "decimalLatitude", "year", "basisOfRecord")
    keep <- intersect(keep, names(df))
    df <- df[, keep, drop = FALSE]
    df <- df[complete.cases(df$decimalLongitude, df$decimalLatitude), ]
    df <- unique(df)

    message("  ", nrow(df), " clean records for ", sp)
    df
  })

  all_data <- do.call(rbind, all_data)

  if (is.null(all_data) || nrow(all_data) == 0) {
    stop("No GBIF records found for the selected pollinators in Morocco.")
  }

  rownames(all_data) <- NULL
  message("Total pollinator records: ", nrow(all_data))
  all_data
}
