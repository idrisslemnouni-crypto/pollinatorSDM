#' Generate automatic report
#'
#' Génère un rapport HTML de synthèse du workflow pollinatorSDM.
#'
#' @param pollinator_data données d'occurrences nettoyées
#' @param model modèle entraîné
#' @param prediction_raster raster de prédiction
#' @param pollination_deficit raster déficit de pollinisation
#' @param recommendations data.frame de recommandations
#' @param output_file nom ou chemin du fichier HTML de sortie
#' @return chemin du fichier généré
#' @export
generate_report <- function(pollinator_data,
                            model,
                            prediction_raster,
                            pollination_deficit,
                            recommendations,
                            output_file = "pollinator_report.html") {

  template <- tempfile(fileext = ".Rmd")

  out_path <- normalizePath(output_file, winslash = "/", mustWork = FALSE)
  if (!grepl("\\.html$", out_path, ignore.case = TRUE)) {
    out_path <- paste0(out_path, ".html")
  }

  out_dir <- dirname(out_path)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

  mean_def <- terra::global(pollination_deficit, "mean", na.rm = TRUE)[1, 1]

  rec_text <- paste(capture.output(print(recommendations)), collapse = "\n")

  rmd_lines <- c(
    "---",
    "title: \"PollinatorSDM Report\"",
    "output: html_document",
    "---",
    "",
    "# Summary",
    "",
    paste("Number of pollinator records:", nrow(pollinator_data)),
    "",
    "# Model",
    "",
    paste("Model class:", class(model)[1]),
    "",
    "# Prediction raster",
    "",
    paste("Raster layers:", terra::nlyr(prediction_raster)),
    "",
    "# Pollination deficit",
    "",
    paste("Mean deficit:", round(mean_def, 4)),
    "",
    "# Recommendations",
    "",
    "```",
    rec_text,
    "```"
  )

  writeLines(rmd_lines, template)

  rendered <- rmarkdown::render(
    input = template,
    output_file = basename(out_path),
    output_dir = out_dir,
    quiet = TRUE,
    envir = new.env(parent = globalenv())
  )

  normalizePath(rendered, winslash = "/", mustWork = TRUE)
}
