source("forestPhenology/000_setup.R")

#Creating training data
ncores = parallel::detectCores()-1

res = c("res5","res10","res15","res25")

trees = readOGR("data/trees_buffer.shp")
trees$ID = 1:length(trees)
# trees to list for parallel processing
treesLS = lapply(1:length(trees), function(x){
  y = trees[x,]
  return(y)
})

for (i in seq(length(res))) {
  print(paste0("Starting ", res[i])) 
  RGB = raster::stack(list.files("data/resampled", pattern=res[i], full.names=TRUE))
  RGB_names = readRDS("data/resampled/names_RGB_stack.rds")
  names(RGB) = RGB_names
  
  IND = raster::stack(list.files("data/indices", pattern=res[i], full.names=TRUE))
  IND_names = readRDS("data/indices/names_indices_stack.rds")
  names(IND) = IND_names
  
  SES = raster::stack(list.files("data/season", pattern=res[i], full.names=TRUE))
  SES_names = readRDS("data/season/season_names.rds")
  names(SES) = SES_names
  
  predictors = stack(RGB,IND,SES)
  
  # extract data for each tree in parallel
  data = parallel::mclapply(treesLS, function(x){
    tmp = crop(predictors, x)
    tmp = as.data.frame(tmp)
    return(tmp)
  }, mc.cores = ncores)
  
  print(Sys.time())
  print(paste0("Finished extracting ", res[i]))
  for (l in seq(length(data))) {
    data[[l]]$polID = l
  }
  
  data_extract = do.call(rbind,data)
  write.csv2(data_extract, file = paste0("data/results/extract_data_", res[i], ".csv"), sep = ";")
  print(paste0("Wrote ", res[i], ".csv"))
}