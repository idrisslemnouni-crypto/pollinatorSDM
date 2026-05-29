#' Generate management recommendations
#' @param deficit_class Character
#' @return Character
#' @export
generate_recommendations <- function(deficit_class = "eleve") {
  recs <- c(
    faible = "Maintenir les habitats existants. Surveillance recommandee.",
    modere = "Planter des bandes fleuries. Reduire les pesticides.",
    eleve = "Installer des ruches. Creer des haies et corridors ecologiques. Augmenter les habitats semi-naturels."
  )
  recs[deficit_class]
}
