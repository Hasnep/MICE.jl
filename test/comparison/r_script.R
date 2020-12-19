datasets <- list(nhanes = mice::nhanes, msleep = ggplot2::msleep)

for (i in seq_along(datasets)) {
  dataset <- datasets[[i]]  
  dataset <- dplyr::select_if(dataset, is.numeric)
  dataset_name <- names(datasets)[[i]]
  write.csv(dataset, here::here("data","input", paste0(dataset_name, ".csv")), row.names = F, quote = F)
  imputed <- mice::complete(mice::mice(dataset, m = 5))
  write.csv(imputed, here::here("data", "output", paste0(dataset_name, "_imputed.csv")), row.names = F, quote = F)
}
