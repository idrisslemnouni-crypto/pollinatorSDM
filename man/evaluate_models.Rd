\name{evaluate_models}
\alias{evaluate_models}
\title{Evaluate a binary SDM with a fixed decision threshold}
\usage{evaluate_models(model, test_data, threshold = 0.5)}
\arguments{
\item{model}{A trained binary randomForest classifier.}
\item{test_data}{A data.frame with occurrence labels 0/1 and predictors.}
\item{threshold}{Fixed probability threshold in [0, 1], default 0.5.}
}
\value{A list with AUC, Accuracy, Sensitivity, Specificity, Threshold, metrics, roc_plot and roc_object.}
\description{Test labels never select the threshold. Use select_sdm_threshold on independent validation data first. The ROC direction is fixed: larger probabilities indicate occurrence even when discrimination is poor.}
