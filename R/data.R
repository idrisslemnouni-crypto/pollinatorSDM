#' Dépendances des cultures à la pollinisation
#'
#' Jeu de données sur les principales cultures agricoles dépendantes de la
#' pollinisation entomophile, avec leur coefficient de dépendance estimé.
#'
#' @format Un data.frame avec 15 lignes et 5 variables :
#' \describe{
#'   \item{crop}{Nom français de la culture}
#'   \item{crop_type}{Catégorie : fruitier, oleagineux, legume, aromatique, fourrager}
#'   \item{poll_dependency}{Coefficient de dépendance à la pollinisation (0-1)}
#'   \item{area_ha}{Surface agricole estimée en France (hectares)}
#'   \item{region}{Région de référence}
#' }
#'
#' @source Klein, A.M. et al. (2007). Importance of pollinators in changing
#'   landscapes for world crops. \emph{Proceedings of the Royal Society B},
#'   274(1608), 303-313.
#'
#' @examples
#' data(crop_dependencies)
#' head(crop_dependencies)
#' hist(crop_dependencies$poll_dependency,
#'      main = "Distribution des coefficients de dépendance",
#'      xlab = "Dépendance à la pollinisation")
"crop_dependencies"
