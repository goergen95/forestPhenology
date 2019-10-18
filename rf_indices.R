source("forestPhenology/000_setup.R")

res = c("res25")
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
  traindat = traindat[, c(1, length(traindat), 2:111)]
  traindat = traindat[, c(1:3, 22:63)]
  
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
  mod1_indices = CAST::ffs(predictors = pred, response = resp, method = "rf", importance = TRUE, trControl = trainctl, 
                          metric = "Kappa")
  #Saving model to disk
  saveRDS(mod1_indices, paste0("data/results/mod1_indices_", res[i], ".rds"))
  print(pate0("Finished model 1: ", Sys.time()))
  gc()
}

mod1_indices_res25 = readRDS("data/results/mod1_indices_res25.rds")

test = predict(mod1_indices_res25, traindat[index,])
conf = caret::confusionMatrix(test, traindat$specID[index])

RGB = raster::stack(list.files("data/resampled", pattern=res[i], full.names=TRUE))
RGB_names = readRDS("data/resampled/names_RGB_stack.rds")
names(RGB) = RGB_names

IND = raster::stack(list.files("data/indices", pattern=res[i], full.names=TRUE))
IND_names = readRDS("data/indices/names_indices_stack.rds")
names(IND) = IND_names

SES = raster::stack(list.files("data/season", pattern=res[i], full.names=TRUE))
SES_names = readRDS("data/season/season_names.rds")
names(SES) = SES_names

sta = stack(RGB,IND,SES)

areapred = raster::predict(sta, mod1_indices_res25)
writeRaster(areapred, "data/results/mod1_indices_res25_areapred.tif", overwrite = TRUE)

