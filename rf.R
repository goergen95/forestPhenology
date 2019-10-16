source("forestPhenology/000_setup.R")

res = c("res5","res10","res15","res25")
trees = rgdal::readOGR("data/trees_buffer.shp")
trees@data$polID = seq(nrow(trees@data))

autoStopCluster = function(cl) {
  stopifnot(inherits(cl, "cluster"))
  env = new.env()
  env$cluster = cl
  attr(cl, "gcMe") = env
  reg.finalizer(env, function(e) {
    message("Finalizing cluster ...")
    message(capture.output(print(e$cluster)))
    try(parallel::stopCluster(e$cluster), silent = FALSE)
    message("Finalizing cluster ... done")
  })
  cl
}

for (i in seq(length(res))){
  print(paste0("Processing: ", res[i]))
  data = read.csv2(paste0("data/results/extract_data_", res[i], ".csv"), header = TRUE, sep = ";")
  traindat = merge(data, trees@data [, c("polID" ,"specID")], by = "polID")
  traindat = traindat[,c(1, length(traindat), 2:111)]
  
  #Split data 70/30; save 30% for prediction and validation
  print(paste0("Started model 1: ", Sys.time()))
  set.seed(1899)
  index = caret::createDataPartition(y = traindat$polID, p = .70, list = FALSE)
  pred = traindat[-index, -which(names(traindat) %in% c("specID", "X"))]
  resp = traindat[-index, which(names(traindat) == "specID")]
  ind = CAST::CreateSpacetimeFolds(pred, spacevar = "polID", k = 5)
  trainctl = caret::trainControl(method = "cv", number = 5, classProbs = TRUE, 
                                  index = ind$index, indexOut = ind$indexOut, savePredictions = TRUE, returnResamp = "all")
  pred = pred[, -which(names(pred) == "polID")]
  
  cl = autoStopCluster(parallel::makeCluster(parallel::detectCores()-1))
  doParallel::registerDoParallel(cl)
  mod1 = CAST::ffs(predictors = pred, response = resp, method = "rf", importance = TRUE, trControl = trainctl, 
                    metric = "Kappa")
  mod1 = caret::train(pred, resp, method = "rf", trControl = trainctl)
  #Saving model to disk
  saveRDS(mod1, paste0("data/results/mod1_", res[i], ".rds"))
  print(pate0("Finished model 1: ", Sys.time()))
  gc()
}