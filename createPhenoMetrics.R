library(raster)
library(rgdal)
# better run the script of photos which already have equal resolution


# first we create some RGB vegetation indices, which proved useful in last years semester courses

rgbIndices <- function(rgb,rgbi=c("TGI","GLI","CIVE")){
  
  red = rgb[[1]]
  green = rgb[[2]]
  blue = rgb[[3]]
  
  
  indices <- lapply(rgbi, function(item){
    if (item=="TGI"){
      # Triangular greenness index
      cat("\ncalculate Triangular greenness index (TGI)")
      TGI <- -0.5*(190*(red - green)- 120*(red - blue))
      names(TGI) <- "TGI"
      return(TGI)
    } else if (item=="GLI"){
      cat("\ncalculate green leaf index (GLI)")
      # green leaf index
      GLI<-(2*green-red-blue)/(2*green+red+blue)
      names(GLI) <- "GLI"
      return(GLI)
    } else if (item=="CIVE"){
      # Color Index of Vegetation (CIVE): 0.441*R - 0.881*G + 0.385*B + 18.787
      cat("\ncalculate Color Index of Vegetation (CIVE)")
      CIVE<-(0.441*red-0.881*green+0.385*blue+18.787)
      names(CIVE) <- "CIVE"
      return(CIVE)
    }
  })
  return(raster::stack(indices))
}


photos = list.files("data/",pattern=".tif",full.names = TRUE)
photos = lapply(photos,stack)
rem4=function(x){
  #remove the 4th band from each tif
  tmp=x[[-4]]
  return(tmp)
}
photos=lapply(photos, rem4)

indices = lapply(photos,rgbIndices)
