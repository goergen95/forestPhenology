# script to apply indices and phenometrics function to raster data
source("forestPhenology/fun/phenoFun.R")
source("forestPhenology/fun/sampleFuns.R")
source("forestPhenology/000_setup.R")

loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","rgeos","gdalUtils","sp","stringr", "parallel")
lapply(libs,loadandinstall)

ncores = parallel::detectCores() - 1

trees = readOGR("data/trees_buffer.shp")
files = list.files("data/resampled",patter=".tif",full.names = TRUE)
dates = readRDS("data/resampled/dates.rds")
days = dates[seq(1,length(dates),3)]

for (file in files){
  RGBseries = raster::brick(file)
  res = stringr::str_split(file,"/")[[1]][3]
  names(RGBseries) = dates
  steps = seq(1,raster::nlayers(RGBseries),3)
  for (step in steps){
    DOY = dates[step]
    indices = rgbIndices(RGBseries[[seq(step,step+2,1)]],rgbi=c("TGI","GLI","CIVE","IO","VVI","GCC","RCC"))
    writeRaster(indices,filename=paste0("data/indices/indices_",DOY,"_",res),overwrite=TRUE)
  }
}
names_indices = names(indices)
saveRDS(names_indices, file = "data/indices/names_indices.rds")
rm(indices,RGBseries,res,steps,DOY)
gc()
# apply pheno metrics for all resolutions
res = c("res25","res15","res10","res5")

for (r in res){
  files = list.files("data/indices",pattern=r,full.names = TRUE)
  tmp = raster::stack(files)
  TGI = tmp[[seq(length(names_indices)-6,nlayers(tmp)-6,length(names_indices))]]
  names(TGI) = paste("TGI_", days, sep="")
  saveRDS(names(TGI), file = "data/indices/time_series/TGI_names.rds")
  raster::writeRaster(TGI, filename=paste0("data/indices/time_series/TGI_timeseries_",r,".tif"),overwrite=TRUE)
  GLI = tmp[[seq(length(names_indices)-5,nlayers(tmp)-5,length(names_indices))]]
  names(GLI) = paste("GLI_", days, sep="")
  saveRDS(names(GLI), file = "data/indices/time_series/GLI_names.rds")
  raster::writeRaster(GLI, filename=paste0("data/indices/time_series/GLI_timeseries_",r,".tif"),overwrite=TRUE)
  CIVE = tmp[[seq(length(names_indices)-4,nlayers(tmp)-4,length(names_indices))]]
  names(CIVE) = paste("CIVE_", days, sep="")
  saveRDS(names(CIVE), file = "data/indices/time_series/CIVE_names.rds")
  raster::writeRaster(CIVE, filename=paste0("data/indices/time_series/CIVE_timeseries_",r,".tif"),overwrite=TRUE)
  IO = tmp[[seq(length(names_indices)-3,nlayers(tmp)-3,length(names_indices))]]
  names(IO) = paste("IO_", days, sep="")
  saveRDS(names(IO), file = "data/indices/time_series/IO_names.rds")
  raster::writeRaster(IO, filename=paste0("data/indices/time_series/IO_timeseries_",r,".tif"),overwrite=TRUE)
  VVI = tmp[[seq(length(names_indices)-2,nlayers(tmp)-2,length(names_indices))]]
  names(VVI) = paste("VVI_", days, sep="")
  saveRDS(names(VVI), file = "data/indices/time_series/VVI_names.rds")
  raster::writeRaster(VVI, filename=paste0("data/indices/time_series/VVI_timeseries_",r,".tif"),overwrite=TRUE)
  GCC = tmp[[seq(length(names_indices)-1,nlayers(tmp)-1,length(names_indices))]]
  names(GCC) = paste("GCC_", days, sep="")
  saveRDS(names(GCC), file = "data/indices/time_series/GCC_names.rds")
  raster::writeRaster(GCC, filename=paste0("data/indices/time_series/GCC_timeseries_",r,".tif"),overwrite=TRUE)
  RCC = tmp[[seq(length(names_indices),nlayers(tmp),length(names_indices))]]
  names(RCC) = paste("RCC_", days, sep="")
  saveRDS(names(RCC), file = "data/indices/time_series/RCC_names.rds")
  raster::writeRaster(RCC, filename=paste0("data/indices/time_series/RCC_timeseries_",r,".tif"),overwrite=TRUE)
  
  print(paste0("Starting with seasonal parameters for ",r,"."))
  metrics = calcPheno(TGI,cores=ncores)
  raster::writeRaster(metrics, filename=paste0("data/season/season_TGI_",r,".tif"),overwrite=TRUE)
  print("Finished TGI parameters.")
  metrics = calcPheno(GLI,cores=ncores)
  raster::writeRaster(metrics, filename=paste0("data/season/season_GLI_",r,".tif"),overwrite=TRUE)
  print("Finished GLI parameters.")
  metrics = calcPheno(CIVE,cores=ncores)
  raster::writeRaster(metrics, filename=paste0("data/season/season_CIVE_",r,".tif"),overwrite=TRUE)
  print("Finished CIVE parameters.")
  metrics = calcPheno(IO,cores=ncores)
  raster::writeRaster(metrics, filename=paste0("data/season/season_IO_",r,".tif"),overwrite=TRUE)
  print("Finished IO parameters.")
  metrics = calcPheno(VVI,cores=ncores)
  raster::writeRaster(metrics, filename=paste0("data/season/season_VVI_",r,".tif"),overwrite=TRUE)
  print("Finished VVI parameters.")
  metrics = calcPheno(GCC,cores=ncores)
  raster::writeRaster(metrics, filename=paste0("data/season/season_GCC_",r,".tif"),overwrite=TRUE)
  print("Finished GCC parameters.")
  metrics = calcPheno(RCC,cores=ncores)
  raster::writeRaster(metrics, filename=paste0("data/season/season_RCC_",r,".tif"),overwrite=TRUE)
  print("Finished RCC parameters.")
  rm(TGI,GLI,CIVE,IO,VVI,GCC,RCC,metrics)
  gc()
}
