
# first we create some RGB vegetation indices, which proved useful in last years semester courses
# should add VVI and IO, because both achived high variable importance for group bjcm 
# IO index: 03 Red - Blue - Ratio (for Iron Oxides = IO)

rgbIndices <- function(rgb,rgbi=c("TGI","GLI","CIVE","IO","VVI","GCC","RCC")){
  
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
      
    } else if (item=="IO"){
      cat("\ncalculate Iron Oxide Index (IO)")
      # IO index
      IO<-red/blue
      names(IO) <- "IO"
      return(IO)
      
    }else if (item=="VVI"){
      cat("\ncalculate Visible Vegetation Index (VVI)")
      VVI <- (1 - abs((red - 30) / (red + 30))) * 
        (1 - abs((green - 50) / (green + 50))) * 
        (1 - abs((blue - 1) / (blue + 1)))
      names(VVI) <- "VVI"
      return(VVI)
      
    }else if (item=="GCC"){
      cat("\nexcess greenness and green chromatic coordinate (GCC)")
      GCC <- (green / (red+green+blue))
      names(GCC) <- "GCC"
      return(GCC)
      
    }else if (item=="RCC"){
      cat("\nred chromatic coordinate (RCC)")
      RCC <- (red / (red+green+blue))
      names(RCC) <- "RCC"
      return(RCC)
    }
    
  })
  
  return(raster::stack(indices))
}



# function to calculate seasonal paramters
calcPheno = function(index,cores){
  MAX = index[[1]]
  MIN = index[[1]]
  AMP = index[[1]]
  SUM = index[[1]]
  SD = index[[1]]
  Q25 = index[[1]]
  Q75 = index[[1]]
  
  dataArray = array(index,dim=dim(index))
  
  cl = makeCluster(cores)
  MAX[] = parallel::parApply(cl, dataArray, MARGIN=c(1,2), FUN=function(x) max(x,na.rm=TRUE))
  MIN[] = parallel::parApply(cl, dataArray, MARGIN=c(1,2), FUN=function(x) min(x,na.rm=TRUE))
  AMP[] = MAX - MIN
  SUM[] = parallel::parApply(cl, dataArray, MARGIN=c(1,2), FUN=function(x) sum(x,na.rm=TRUE))
  SD[] = parallel::parApply(cl, dataArray, MARGIN=c(1,2), FUN=function(x) sd(x,na.rm=TRUE))
  Q25[] = parallel::parApply(cl, dataArray, MARGIN=c(1,2), FUN=function(x) quantile(x,probs=c(.25),type=7,na.rm=TRUE))
  Q75[] = parallel::parApply(cl, dataArray, MARGIN=c(1,2), FUN=function(x) quantile(x,probs=c(.75),type=7,na.rm=TRUE))
  stopCluster(cl)
  #MAX[] = apply(dataArray,c(1,2),function(x) max(x, na.rm=TRUE))
  #MIN[] = apply(dataArray,c(1,2),function(x) min(x, na.rm=TRUE))
  #AMP = MAX - MIN
  #SUM[] = apply(dataArray,c(1,2),function(x) sum(x, na.rm=TRUE))
  #SD[] = apply(dataArray,c(1,2),function(x) sd(x, na.rm=TRUE))
  #Q25[] = apply(dataArray,c(1,2),function(x) quantile(x,probs=c(.25),type=7,na.rm=TRUE))
  #Q75[] = apply(dataArray,c(1,2),function(x) quantile(x,probs=c(.75),type=7,na.rm=TRUE))
  
  metrics = stack(MAX,MIN,AMP,SUM,SD,Q25,Q75)
  VIname = str_split(names(index)[1],"_")[[1]][1]
  names(metrics) = paste(VIname,c("_MAX","_MIN","_AMP","_SUM","_SD","_Q25","_Q75"),sep="")
  return(metrics)
}

