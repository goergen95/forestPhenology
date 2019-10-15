loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","rgeos","gdalUtils","sp","stringr","parallel")
lapply(libs,loadandinstall)

ncores = parallel::detectCores()-1

#Resample tifs | adapted to the new files
photos = list.files("data",pattern=".tif",full.names = TRUE)
photos = photos[-grep("2019_04_18", photos)]
photos = photos[-grep("2019_04_20", photos)]
photos = photos[-grep("2019_04_23", photos)]

photos = lapply(photos,raster::stack)
rem4=function(x){
  #remove the 4th band from each tif
  tmp=x[[-4]]
  return(tmp)
}
photos= parallel::mclapply(photos, rem4, mc.cores = ncores)

# target projection: utm32 wgs84
proj = "+proj=utm +zone=32 +datum=GRS80 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"


#Load trees in order to crop to the right extend
trees = rgdal::readOGR("data/trees_final.shp")
trees_buffer = rgeos::gBuffer(trees, byid = TRUE, width = 1.5, capStyle = "SQUARE")
index = as.data.frame(rgeos::gDisjoint(trees_buffer, byid = TRUE))
index = which(colSums(index)<length(trees_buffer)-1)
trees_buffer = trees_buffer[-index,]
trees_buffer = trees_buffer[trees_buffer$specID == "BUR" | trees_buffer$specID == "EIT",]
writeOGR(trees_buffer, "data/trees_buffer.shp", driver ="ESRI Shapefile", layer = "trees_buffer", overwrite_layer = T)

trees = trees_buffer
trees$treeID = as.factor(trees$treeID)
trees$ID = 1:length(trees)
treesBuff = rgeos::gBuffer(trees, width = 5)
sp::proj4string(trees) = sp::CRS(sp::proj4string(photos[[1]]))
ext = sp::bbox(rgeos::gBuffer(treesBuff,byid=FALSE, width=5))

cropTifs = function(x){
  tmp = raster::crop(x,ext)
  return(tmp)
}
photos = parallel::mclapply(photos, cropTifs, mc.cores = ncores)

mask = photos[[1]]
resTifs = function(x){
  tmp = raster::resample(x,mask)
  return(tmp)}

photos = parallel::mclapply(photos,resTifs, mc.cores = ncores)
photos = raster::stack(photos)

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
