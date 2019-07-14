#Fixing names for rasterstacks
res = c("res5","res10","res15","res25")

RGB_names = readRDS("data/resampled/dates.rds")
RGB = raster::stack(list.files("data/resampled", pattern=res[3], full.names=TRUE))
names(RGB) = paste0(RGB_names, "_", res[3])
saveRDS(names(RGB), file = "data/resampled/names_RGB_stack.rds")

IND_names = readRDS("data/indices/names_indices.rds")
IND = raster::stack(list.files("data/indices", pattern=res[3], full.names=TRUE))
DOY = unique(RGB_names)
ind_dates = c()
for (day in DOY){
  c = rep(day, length(IND_names))
  ind_dates = c(ind_dates, c)
}
IND_names = rep(paste0(IND_names), length(DOY))
names(IND) = paste0(ind_dates, "_", IND_names)
saveRDS(names(IND), file = "data/indices/names_indices_stack.rds")

SES = raster::stack(list.files("data/season", pattern=res[3], full.names=TRUE))
SES_names = rep(c("MAX","MIN","AMP","SUM","SD","Q25","Q75"), 7)
names(SES) = paste0(substr(names(SES), 1, nchar(names(SES))-7), SES_names)
saveRDS(names(SES), file = "data/season/season_names.rds")