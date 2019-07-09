loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","sp")
lapply(libs,loadandinstall)

#Converting .csv file to point shapefile
trees = read.csv("data/trees_20190611.csv", sep = ";")
crs = "+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
coords = trees[,2:3]

treeshape = SpatialPointsDataFrame(coords=coords,proj4string = CRS(crs),data=trees[,c(1,4:8)])
treeshape@data
writeOGR(treeshape,dsn="data/trees.shp",driver="ESRI Shapefile",layer="trees")
