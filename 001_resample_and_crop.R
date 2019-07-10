loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","rgeos","gdalUtils","sp","stringr")
lapply(libs,loadandinstall)

#Resample tifs | adapted to the new files
photos = list.files("data/",pattern=".tif",full.names = TRUE)
photos = photos[-grep("2019_04_23", photos)]

photos = lapply(photos,raster::stack)
rem4=function(x){
  #remove the 4th band from each tif
  tmp=x[[-4]]
  return(tmp)
}
photos=lapply(photos, rem4)

# target projection: utm32 wgs84
proj = "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"


#Load trees in order to crop to the right extend
trees = rgdal::readOGR("data/trees.shp")
trees$treeID = as.factor(trees$treeID)
trees$ID = 1:length(trees)
treesBuff = rgeos::gBuffer(trees, byid=TRUE, width = 4)
trees = spTransform(trees, CRSobj = crs(photos[[1]]))

ext = sp::bbox(rgeos::gBuffer(treesBuff,byid=FALSE, width=10))

cropTifs = function(x){
  tmp = raster::crop(x,ext)
  return(tmp)
}
photos = lapply(photos, cropTifs)

mask = photos[[1]]
resTifs = function(x){
  tmp = raster::resample(x,mask)
  return(tmp)}

photos = lapply(photos,resTifs)
photos = raster::stack(photos)

# projection to target projection (UTM32 - WGS84)
photos = projectRaster(photos,crs=proj)
trees = spTransform(trees,CRSobj=proj)

# 10, 15, 25 cm resolution data
tmp = raster::raster(crs=proj4string(photos),ext=extent(photos),resolution=0.10)
res10 = raster::resample(photos,tmp)
tmp = raster::raster(crs=proj4string(photos),ext=extent(photos),resolution=0.15)
res15 = raster::resample(photos,tmp)
tmp = raster::raster(crs=proj4string(photos),ext=extent(photos),resolution=0.25)
res25 = raster::resample(photos,tmp)

raster::writeRaster(photos, filename = "data/resampled/res5.tif",overwrite=TRUE)
raster::writeRaster(res10, filename = "data/resampled/res10.tif",overwrite=TRUE)
raster::writeRaster(res15, filename = "data/resampled/res15.tif",overwrite=TRUE)
raster::writeRaster(res25, filename = "data/resampled/res25.tif",overwrite=TRUE)

dates = stringr::str_sub(names(photos),-24,-15)
saveRDS(dates, file ="data/resampled/dates.rds")
