root_folder <- envimaR::alternativeEnvi(root_folder = "~/edu/mpg-envinsys-plygrnd", alt_env_id = "COMPUTERNAME",
                                        alt_env_value = "PCRZP", alt_env_root_folder = "D:/Master/mpg-envinsys-plygrnd/Umweltinfo/")

##loading librarys
x <-  c("RODBC", "tidyverse","dplyr", "reshape2", "FedData")
for (i in 1:length(x)){
  if(x[i] %in% rownames(installed.packages()) == FALSE) {install.packages(x[i])}
}
lapply(x, require, character.only = TRUE)

# checking directory

mainDir= "D:/Master/mpg-envinsys-plygrnd/Umweltinfo/"
subDir= c("data/",
          "data/indices/", "data/indices/time_series/", 
          "data/resampled/", 
          "data/season/",
          "forestPhenolog/",
          "forestPhenolog/doc/",
          "forestPhenolog/fun/",
          "results/")

ifelse(!dir.exists(mainDir, subDir), dir.create(mainDir, subDir), FALSE)

for (i in 1:length(subDir)) {
  if (file.exists(subDir[i])){
    setwd(file.path(mainDir, subDir[i]))
  } else {
    dir.create(file.path(mainDir, subDir[i]))
    setwd(file.path(mainDir, subDir[i]))
  }
}
