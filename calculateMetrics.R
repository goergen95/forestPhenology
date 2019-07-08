# script to apply indices and phenometrics function to raster data
source("forestPhenology/phenoFun.R")
source("forestPhenology/sampleFuns.R")
loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","rgeos","gdalUtils","sp","stringr")
lapply(libs,loadandinstall)


trees = readOGR("data/artTrees.shp")
files = list.files("data/resampled",patter=".tif",full.names = TRUE)
dates = readRDS("data/resampled/dates.rds")
days = dates[seq(1,length(dates),3)]

for (file in files){
  RGBseries = raster::brick(file)
  res = stringr::str_split(file,"/")[[1]][3]
  names(RGBseries) = dates
  steps = seq(1,nlayers(RGBseries),3)
  for (step in steps){
    DOY = dates[step]
    indices = rgbIndices(RGBseries[[seq(step,step+2,1)]],rgbi=c("TGI","GLI","CIVE","IO","VVI","GCC","RCC"))
    writeRaster(indices,filename=paste0("data/indices/indices_",DOY,"_",res),overwrite=TRUE)
  }
}


# apply pheno metrics for all resolutions
res = c("res5","res8","res12","res25")

for (r in res){

files = list.files("data/indices/",pattern=r,full.names = TRUE)
tmp = raster::stack(files)
TGI = tmp[[seq(1,57,7)]]
names(TGI) = paste("TGI_", days, sep="")
GLI = tmp[[seq(2,58,7)]]
names(GLI) = paste("GLI_", days, sep="")
CIVE = tmp[[seq(3,59,7)]]
names(CIVE) = paste("CIVE_", days, sep="")
IO = tmp[[seq(4,60,7)]]
names(IO) = paste("IO_", days, sep="")
VVI = tmp[[seq(5,61,7)]]
names(VVI) = paste("VVI_", days, sep="")
GCC = tmp[[seq(6,62,7)]]
names(GCC) = paste("GCC_", days, sep="")
RCC = tmp[[seq(7,63,7)]]
names(RCC) = paste("RCC_", days, sep="")

print(paste0("Starting with seasonal parameters for ",r,"."))
metrics = calcPheno(TGI) 
raster::writeRaster(metrics, filename=paste0("data/season/season_TGI_",r,".tif"),overwrite=TRUE)
print("Finished TGI parameters.")
metrics = calcPheno(GLI) 
raster::writeRaster(metrics, filename=paste0("data/season/season_GLI_",r,".tif"),overwrite=TRUE)
print("Finished GLI parameters.")
metrics = calcPheno(CIVE) 
raster::writeRaster(metrics, filename=paste0("data/season/season_CIVE_",r,".tif"),overwrite=TRUE)
print("Finished CIVE parameters.")
metrics = calcPheno(IO) 
raster::writeRaster(metrics, filename=paste0("data/season/season_IO_",r,".tif"),overwrite=TRUE)
print("Finished IO parameters.")
metrics = calcPheno(VVI) 
raster::writeRaster(metrics, filename=paste0("data/season/season_VVI_",r,".tif"),overwrite=TRUE)
print("Finished VVI parameters.")
metrics = calcPheno(GCC) 
raster::writeRaster(metrics, filename=paste0("data/season/season_GCC_",r,".tif"),overwrite=TRUE)
print("Finished GCC parameters.")
metrics = calcPheno(RCC) 
raster::writeRaster(metrics, filename=paste0("data/season/season_RCC_",r,".tif"),overwrite=TRUE)
print("Finished RCC parameters.")
rm(TGI,GLI,CIVE,IO,VVI,GCC,RCC,metrics)
gc()
}


RGB = raster::stack(list.files("data/resampled/", pattern=res[3], full.names=TRUE))
IND = raster::stack(list.files("data/indices/", pattern=res[3], full.names=TRUE))
SES = raster::stack(list.files("data/season/", pattern=res[3], full.names=TRUE))
predictors = stack(RGB,IND,SES)
data  = sampleAll(predictors, trees, overlap=TRUE,category="specID")
data2 = sampleAll(predictors,trees,overlap=FALSE,category="specID")
data3 = sampleRand(predictors=predictors,trees=trees,objectbased=FALSE,category="specID",nPix=1000,res=0.12)
data4 = sampleRand(predictors,trees,objectbase=TRUE,category="specID",nPix=50,res=0.12)

test = velox::velox(predictors)
testdata = test$extract(trees,df = TRUE)
testsd = test$extract(trees,df=TRUE,fun=sd)
