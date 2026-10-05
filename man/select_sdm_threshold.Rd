\name{select_sdm_threshold}
\alias{select_sdm_threshold}
\title{Select a decision threshold using independent validation data}
\usage{select_sdm_threshold(model, validation_data)}
\arguments{
\item{model}{A trained binary randomForest classifier.}
\item{validation_data}{Independent labelled validation data.}
}
\value{One numeric threshold in [0, 1].}
\description{Selects a Youden threshold with fixed ROC direction. Ties use proximity to 0.5, then the smaller threshold; constant scores use 0.5. Validation observations must be separate from training and evaluation.}
