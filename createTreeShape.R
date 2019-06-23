#Converting .csv file to point shapefile
library(rgdal)
library(sp)
trees = read.csv("../data/trees_20190611.csv", sep = ";")
crs = "+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
coords = trees[,2:3]

treeshape = SpatialPointsDataFrame(coords=coords,proj4string = CRS(crs),data=trees[,c(1,4:8)])
treeshape@data
writeOGR(treeshape,dsn="../results/trees.shp",driver="ESRI Shapefile",layer="trees")
