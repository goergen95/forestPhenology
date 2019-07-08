loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","rgeos","gdalUtils","sp","stringr")
lapply(libs,loadandinstall)


#Resample tifs | adapted to the new files
photos = list.files("data/",pattern=".tif",full.names = TRUE)
photos = lapply(photos,raster::stack)
rem4=function(x){
  #remove the 4th band from each tif
  tmp=x[[-4]]
  return(tmp)
}
photos=lapply(photos, rem4)

ext = sp::bbox(rgeos::gBuffer(treesBuff,byid=FALSE, width=10))

cropTifs = function(x){
  tmp = raster::crop(x,ext)
  return(tmp)
}
photos = lapply(photos, cropTifs)

maske = photos[[1]]
resTifs = function(x){
  tmp = raster::resample(x,maske)
  return(tmp)
}
photos = lapply(photos,resTifs)
photos = raster::stack(photos)

# 4, 8, 12, 25 cm resolution data
tmp = raster::raster(crs=proj4string(photos),ext=extent(photos),resolution=0.04)
res4 = raster::resample(photos,tmp)
tmp = raster::raster(crs=proj4string(photos),ext=extent(photos),resolution=0.08)
res8 = raster::resample(photos,tmp)
tmp = raster::raster(crs=proj4string(photos),ext=extent(photos),resolution=0.12)
res12 = raster::resample(photos,tmp)
tmp = raster::raster(crs=proj4string(photos),ext=extent(photos),resolution=0.25)
res25 = raster::resample(photos,tmp)

raster::writeRaster(res4, filename = "data/resampled/res4.tif",overwrite=TRUE)
raster::writeRaster(res8, filename = "data/resampled/res8.tif",overwrite=TRUE)
raster::writeRaster(res12, filename = "data/resampled/res12.tif",overwrite=TRUE)
raster::writeRaster(res25, filename = "data/resampled/res25.tif",overwrite=TRUE)

dates = stringr::str_sub(names(res4),-12,-1)
saveRDS(dates, file ="data/resampled/dates.rds")