if(Sys.info()["sysname"] == "Windows"){
  root_folder = "~/pheno"
} else {
  root_folder = "~/pheno"
  }
##loading librarys
loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs <-  c("RODBC", 
          "dplyr", 
          "reshape2", 
          "ggplot2",
          "magrittr",
          "caret",
          "raster",
          "rgdal",
          "rgeos",
          "gdalUtils",
          "sp")
for (lib in libs){loadandinstall(lib)}

# checking directory

mainDir= path.expand(root_folder)
subDir= c("data",
          "data/indices", "data/indices/time_series", 
          "data/resampled", 
          "data/season",
          "forestPhenology",
          "forestPhenology/doc",
          "forestPhenology/fun",
          "results",
          "test")

for (dir in subDir){if(!dir.exists(file.path(mainDir, dir))){dir.create(file.path(mainDir, dir))}}
