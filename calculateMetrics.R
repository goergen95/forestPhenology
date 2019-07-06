# script to apply indices and phenometrics function to raster data
source("forestPhenology/phenoFun.R")
files = list.files("data/resampled/",patter=".tif",full.names = TRUE)
dates = readRDS("data/resampled/dates.rds")


for (file in files){
  RGBseries = raster::brick(file)
  res = stringr::str_split(file,"/")[[1]][3]
  names(RGBseries) = dates
  steps = seq(1,nlayers(RGBseries),3)
  days = unique(stringr::str_sub(dates,0,-3))
  for (step in steps){
    date = stringr::str_sub(names(RGBseries[[seq(step,step+2,1)]])[1],-12,-3)
    indices = rgbIndices(RGBseries[[seq(step,step+2,1)]],rgbi=c("TGI","GLI","CIVE","IO","VVI","GCC","RCC"))
    writeRaster(indices,filename=paste0("data/indices/indices_",days[which(steps==step)],"_",res),overwrite=TRUE)
  }
}
