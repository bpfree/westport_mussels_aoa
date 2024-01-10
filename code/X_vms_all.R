#########################################################
### X. Vessel monitoring system (VMS) --- all fishing ###
#########################################################

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(docxtractr,
               dplyr,
               elsa,
               fasterize,
               fs,
               ggplot2,
               janitor,
               ncf,
               paletteer,
               pdftools,
               plyr,
               purrr,
               raster,
               RColorBrewer,
               reshape2,
               #rgdal,
               rgeoda,
               #rgeos,
               rmapshaper,
               rnaturalearth, # use devtools::install_github("ropenscilabs/rnaturalearth") if packages does not install properly
               sf,
               sp,
               stringr,
               terra, # is replacing the raster package
               tidyr)

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### vessel trip reporting
data_dir <- "data/a_raw_data/vms/vms_fishing/fisheries_all"

#### study area grid
study_region_gpkg <- "data/b_intermediate_data/westport_study_area.gpkg"

### output directories
#### fisheries
fisheries_gpkg <- "data/c_submodel_data/fisheries.gpkg"

#### intermediate directories
vms_all_gpkg <- "data/b_intermediate_data/westport_vms_all.gpkg"

#####################################

# inspect layers within geopackage
sf::st_layers(dsn = study_region_gpkg,
              do_count = T)

#####################################
#####################################

# set parameters
## designate region name
region <- "westport"

## coordinate reference system
### EPSG:26918 is NAD83 / UTM 18N (https://epsg.io/26918)
crs <- "EPSG:26918"

vms_crs <- "ESRI:102008"

## layer names
export_name <- "ais"

## designate date
date <- format(Sys.time(), "%Y%m%d")

#####################################
#####################################

# function
fishery_function <- function(fishery_dir, study_region){
  # load the fishery raster data
  fishery_raster <- terra::rast(paste(data_dir, fishery_dir, "w001001.adf", sep = "/"))
  
  # limit fishery raster data to the study region
  raster <- terra::crop(x = fishery_raster,
                        # crop using study region
                        y = study_region,
                        # mask using study region (T = True)
                        mask = T)
}

## z-membership function
### Adapted from https://www.mathworks.com/help/fuzzy/zmf.html
zmf_function <- function(raster){
  
  # calculate the absolute value of minimum
  value_add <- abs(terra::minmax(raster)[1])
  
  # calculate the rescaled maximum value
  max_value <- terra::minmax(raster)[2] + value_add
  
  # verify against the range
  range <- terra::minmax(raster)[2] - terra::minmax(raster)[1]
  
  print(c(max_value, range))
  
  # new raster with shifted values
  raster_add <- raster + value_add
  plot(raster_add)
  
  # calculate minimum value
  min <- terra::minmax(raster_add)[1,]
  
  # calculate maximum value
  max <- terra::minmax(raster_add)[2,]
  
  # calculate z-score minimum value
  ## this ensures that no value gets a value of 0
  z_max <- max + (max * 1 / 1000)
  
  # calculate z-scores (more desired values get score of 1 while less desired will decrease till 0)
  z_value <- ifelse(raster_add[] == min, 1, # if value is equal to minimum, score as 1
                    # if value is larger than minimum but lower than mid-value, calculate based on reduction equation
                    ifelse(raster_add[] > min & raster_add[] < (min + z_max) / 2, 1 - 2 * ((raster_add[] - min) / (z_max - min)) ** 2,
                           # if value is larger than mid-value but lower than maximum, calculate based on equation
                           ifelse(raster_add[] >= (min + z_max) / 2 & raster[] < z_max, 2*((raster_add[] - z_max) / (z_max - min)) ** 2,
                                  # if value is equal to maximum, score min - (min * 1 / 1000); otherwise give NA
                                  ifelse(raster_add[] == z_max, 0, NA))))
  
  # set values back to the original raster
  zvalues <- terra::setValues(raster, z_value)
  plot(zvalues)
  
  # return the raster
  return(zvalues)
}

#####################################
#####################################

# load data
## study region
westport_region <- sf::st_read(dsn = study_region_gpkg, layer = paste(region, "area", sep = "_")) %>%
  # change projection to match AIS data coordinate reference system
  sf::st_transform(crs = vms_crs)

### Inspect study region coordinate reference system
cat(crs(westport_region))

## hex grid
westport_hex <- sf::st_read(dsn = study_region_gpkg, layer = paste(region, "area_hex", sep = "_"))

#####################################
#####################################

# run z-membership function on each fishery
## 2015 - 2016 fishery data
her_15_16 <- fishery_function("her_2015_2016", westport_region)
mnk_15_16 <- fishery_function("mnk_2015_2016", westport_region)
nms_15_16 <- fishery_function("nms_2015_2016", westport_region)
pel_15_16 <- fishery_function("pel_2015_2016", westport_region)
sco_15_16 <- fishery_function("sco_2015_2016", westport_region)
ses_15_16 <- fishery_function("ses_2015_2016", westport_region)
smb_15_16 <- fishery_function("smb_2015_2016", westport_region)

her_15_16
mnk_15_16
nms_15_16
pel_15_16
sco_15_16
ses_15_16
smb_15_16

# inspect fisheries data
## plots
plot(her_15_16)
plot(mnk_15_16)
plot(nms_15_16)
plot(pel_15_16)
plot(sco_15_16)
plot(ses_15_16)
plot(smb_15_16)

# extents
terra::ext(her_15_16)
terra::ext(mnk_15_16)
terra::ext(nms_15_16)
terra::ext(pel_15_16)
terra::ext(sco_15_16)
terra::ext(ses_15_16)
terra::ext(smb_15_16)

# expand extent
xmin <- min(terra::ext(her_15_16)[1],
            terra::ext(mnk_15_16)[1],
            terra::ext(nms_15_16)[1],
            terra::ext(pel_15_16)[1],
            terra::ext(sco_15_16)[1],
            terra::ext(ses_15_16)[1],
            terra::ext(smb_15_16)[1])
xmin

xmax <- max(terra::ext(her_15_16)[2],
            terra::ext(mnk_15_16)[2],
            terra::ext(nms_15_16)[2],
            terra::ext(pel_15_16)[2],
            terra::ext(sco_15_16)[2],
            terra::ext(ses_15_16)[2],
            terra::ext(smb_15_16)[2])
xmax

ymin <- min(terra::ext(her_15_16)[3],
            terra::ext(mnk_15_16)[3],
            terra::ext(nms_15_16)[3],
            terra::ext(pel_15_16)[3],
            terra::ext(sco_15_16)[3],
            terra::ext(ses_15_16)[3],
            terra::ext(smb_15_16)[3])
ymin

ymax <- max(ext(her_15_16)[4],
            ext(mnk_15_16)[4],
            ext(nms_15_16)[4],
            ext(pel_15_16)[4],
            ext(sco_15_16)[4],
            ext(ses_15_16)[4],
            ext(smb_15_16)[4])
ymax

# raster extent
raster_ext <- c(xmin, xmax, ymin, ymax)

terra::ext(her_15_16) <- raster_ext
terra::ext(mnk_15_16) <- raster_ext
terra::ext(nms_15_16) <- raster_ext
terra::ext(pel_15_16) <- raster_ext
terra::ext(sco_15_16) <- raster_ext
terra::ext(ses_15_16) <- raster_ext
terra::ext(smb_15_16) <- raster_ext

her_15_16
mnk_15_16
nms_15_16
pel_15_16
sco_15_16
ses_15_16
smb_15_16

#####################################
#####################################

# combine all fishery rasters
terra::ext(her_15_16) <- terra::ext(nms_15_16)

fishery_raster <- terra::app(c(#her_15_16,
                               #mnk_15_16,
                               nms_15_16,
                               pel_15_16,
                               #sco_15_16,
                               #ses_15_16,
                               smb_15_16),
                             # take mean values of all fishery rasters (2015 - 2016)
                             fun = mean,
                             # remove any NA values from calculation
                             na.rm = T)
plot(fishery_raster)

#####################################
#####################################

# convert raster to vector data (as polygons)
# convert to polygon
westport_ais_polygon <- terra::as.polygons(x = ais_z,
                                           # do not aggregate all similar values together as single feature
                                           aggregate = F,
                                           # use the values from original raster
                                           values = T) %>%
  # change to simple feature (sf)
  sf::st_as_sf() %>%
  # simplify column name to "richness" (this is the first column of the object, thus the colnames(.)[1] means take the first column name from the high_habitat object)
  dplyr::rename(ais = colnames(.)[1]) %>%
  # add field "layer" and populate with "ais"
  dplyr::mutate(layer = "ais") %>%
  # limit to the study region
  rmapshaper::ms_clip(clip = westport_region) %>%
  # reproject data into a coordinate system (NAD 1983 UTM Zone 18N) that will convert units from degrees to meters
  sf::st_transform(crs = crs)

## inspect vectorized rescaled AIS data (***warning: lots of data, so will take a long time to load; comment out unless want to display data)
# plot(westport_ais_polygon)

#####################################
#####################################

# vessel trip reporting hex grids
westport_ais_hex <- westport_hex[westport_ais_polygon, ] %>%
  # spatially join vessel trip reporting values to Westport hex cells
  sf::st_join(x = .,
              y = westport_ais_polygon,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(index, layer,
                ais) %>%
  # group by the index values as there are duplicates
  dplyr::group_by(index) %>%
  # summarise the fisheries score values
  ## take the maximum value of the AIS score for any that overlap
  ## ***Note: this will provide the most conservation given that
  ##          high values are less desirable
  dplyr::summarise(marine_bird_index = max(ais))

#####################################
#####################################

# export data
## industry, transportation, navigation geopackage
sf::st_write(obj = westport_ais_hex, dsn = industry_gpkg, layer = paste(region, "hex", export_name, date, sep = "_"), append = F)

## ais geopackage
sf::st_write(obj = westport_ais_polygon, dsn = ais_gpkg, layer = paste(region, export_name, "polygon", date, sep = "_"), append = F)
sf::st_write(obj = westport_ais_hex, dsn = ais_gpkg, layer = paste(region, "hex", export_name, date, sep = "_"), append = F)

## ais raster
ais_raster <- dir.create(paste0("data/b_intermediate_data/ais_data"))
raster_dir <- "data/b_intermediate_data/ais_data"

terra::writeRaster(westport_ais, filename = file.path(raster_dir, paste("westport_ais_2022.grd")), overwrite = T)
terra::writeRaster(ais, filename = file.path(raster_dir, paste("ais_2022.grd")), overwrite = T)
terra::writeRaster(ais_z, filename = file.path(raster_dir, paste("westport_ais_2022_rescaled.grd")), overwrite = T)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
