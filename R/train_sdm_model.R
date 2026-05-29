#' Train SDM with Random Forest
#' @param presence data.frame with predictors
#' @param background data.frame with predictors
#' @return randomForest model
#' @export
train_sdm_model <- function(presence, background) {
  presence$presence <- 1

  # Retirer colonnes non-numériques et geometry
  presence <- as.data.frame(presence)
  presence <- presence[, !sapply(presence, function(x) is.list(x) || inherits(x, "sfc"))]

  background <- as.data.frame(background)
  background <- background[, !sapply(background, function(x) is.list(x) || inherits(x, "sfc"))]

  # Conserver seulement les colonnes communes + presence
  common <- intersect(names(presence), names(background))
  common <- setdiff(common, "presence")

  presence <- presence[, c("presence", common)]
  background <- background[, c("presence", common)]

  all <- rbind(presence, background)
  all <- all[, !sapply(all, is.character)]
  all <- na.omit(all)
  all$presence <- as.factor(all$presence)

  randomForest::randomForest(presence ~ ., data = all, ntree = 100)
}
