source("forestPhenology/000_setup.R")
ncores = parallel::detectCores()-1
## read needed data
# shapefile of AOI
#shp = readOGR(paste0(envrmt$path_data_data_mof,"uwcWaldorte_AOI.shp"))
#list lidar files
las_files = list.files(path = "data/pointcloud/", pattern = ".las",
                       full.names = TRUE)

# Write index file for each LAS file to speed up processing
for(las in las_files){
  rlas::writelax(las)
}

# correct las files with uavRst functionality
base::dir.create(paste0("results/pointcloud/"))
trees = rgdal::readOGR("data/trees.shp")


# reclassify ground returns
cl = parallel::makeCluster(ncores)
parallel::clusterExport(cl, c("las_files"), envir=environment())
parallel::clusterEvalQ(cl, c(library(lidR)))
treePos = parallel::parLapply(cl, las_files, function(x){
  x = lidR::readLAS(x)
  y = lidR::lastrees(x, li2012())
  return(y)
})
parallel::stopCluster(cl)

# normalize height values
cl = parallel::makeCluster(ncores)
parallel::clusterExport(cl, c("groundReturns",), envir=environment())
parallel::clusterEvalQ(cl, c(library(lidR)))
normalizedReturns = parallel::parLapply(cl, las_files, function(x){
  y = lidR::lasnormalize(x, tin())
  return(y)
})
parallel::stopCluster(cl)

lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_lidar_prc,"normalized/","{ID}_norm")
mof_snip_norm = lidR::lasnormalize(mof_snip_ground_csf,tin())
rm(mof_snip_ground_csf)
# and create lax files for each LAS file to speed up future processing
las_files = list.files(path = paste0(envrmt$path_data_lidar_prc,"normalized/"), pattern = ".las",
                       full.names = TRUE)
for(las in las_files){
  writelax(las)
}


# clean workspace
rm(mof_snip_norm, las_files, aoi_bb, las_total, shp, las)
gc()
