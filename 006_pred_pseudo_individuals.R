# prediction of tree species on pseudo tree-level
library(rgdal)
library(raster)
library(caret)
library(dplyr)

models = lapply(list.files("forestPhenology/results/", pattern=".rds$", full.names = T), readRDS)
trees = readOGR("data/trees_buffer.shp")
trees@data$polID = seq(nrow(trees@data))
set.seed(1899)
index = caret::createDataPartition(y = trees$polID, p = .70, list = FALSE)

res = c("res25","res15","res10")

predDF = lapply(res, function(x){
  print(x)
  
  models = lapply(list.files("forestPhenology/results/", pattern=x, full.names = T), readRDS)
  
  RGB = raster::stack(list.files("data/resampled", pattern=x, full.names=TRUE))
  RGB_names = readRDS("data/resampled/names_RGB_stack.rds")
  names(RGB) = RGB_names
  
  IND = raster::stack(list.files("data/indices", pattern=x, full.names=TRUE))
  IND_names = readRDS("data/indices/names_indices_stack.rds")
  names(IND) = IND_names
  
  SES = raster::stack(list.files("data/season", pattern=x, full.names=TRUE))
  SES_names = readRDS("data/season/season_names.rds")
  names(SES) = SES_names
  
  predictors = stack(RGB,IND,SES)
  
  tmp_IND = predictors[[names(models[[1]]$trainingData)]]
  pred_IND = predict(tmp_IND, models[[1]])
  pred_tree_IND = raster::extract(pred_IND, trees[index[,1],], df=T)
  
  outcomeIND = pred_tree_IND %>%
    group_by(ID) %>%
    group_map(., ~raster::modal(.$layer))
  
  
  tmp_ALL = predictors[[names(models[[2]]$trainingData)]]
  pred_ALL = predict(tmp_ALL, models[[2]])
  pred_tree_ALL = raster::extract(pred_ALL, trees[index[,1],], df=T)
  
  outcomeALL = pred_tree_ALL %>%
    group_by(ID) %>%
    group_map(., ~raster::modal(.$layer))
  
  tmp_SES = predictors[[names(models[[3]]$trainingData)]]
  pred_SES = predict(tmp_SES, models[[3]])
  pred_tree_SES = raster::extract(pred_SES, trees[index[,1],], df=T)
  
  outcomeSES = pred_tree_SES %>%
    group_by(ID) %>%
    group_map(., ~raster::modal(.$layer))
  
  df_results = data.frame(predIND=unlist(outcomeIND), predSES=unlist(outcomeSES), predALL=unlist(outcomeALL))
  names(df_results) = paste(names(df_results), x, sep = "_")
  return(df_results)
})

predictions = do.call("cbind", predDF)
predictions$index = index
saveRDS(predictions, file ="results/validation_pred.rds")

metrics = predictions %>%
  select(-index) %>%
  map(function(x) factor(x, levels=1:2, labels=c("BUR", "EIT"))) %>%
  map(function(x) caret::confusionMatrix(trees$specID[index[,1]], x)) %>%
  map(function(x) tibble(accuracy = x$overall[1], kappa = x$overall[2] ))

results = do.call("rbind", metrics)
resolutions = stringr::str_sub(names(predictions)[-10],-2,-1)
types = stringr::str_sub(names(predictions)[-10],5, 7)
results$resolution = as.numeric(resolutions)
results$type = types

ggplot(data = results, aes(x=resolution)) +
  geom_point(aes(y=accuracy, shape=type, col=type), size=2)+
  theme_minimal()

