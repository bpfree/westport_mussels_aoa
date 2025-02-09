##############################################################
### 20. Vessel monitoring system (VMS) -- <4 knots fishing ###
##############################################################

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

# set parameters
## designate region name
region_name <- "westport"

## coordinate reference system
### EPSG:26918 is NAD83 / UTM 18N (https://epsg.io/26918)
crs <- "EPSG:26918"

### ESRI:102008 is NAD 1983 Albers North America (https://epsg.io/102008)
data_crs <- "ESRI:102008"

## layer names
layer_name <- "vms_4_5_knot"

## submodel
submodel <- "fisheries"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### vessel trip reporting
data_dir <- "data/a_raw_data/vms/vms_fishing/fisheries_4_5_kt"

#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

### output directories
#### fisheries
submodel <- stringr::str_glue("data/c_submodel_data/{submodel}.gpkg")

#### intermediate directories
output_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_{layer_name}.gpkg")

#####################################

# inspect layers within geopackage
sf::st_layers(dsn = region_gpkg,
              do_count = T)

#####################################
#####################################

# function
fishery_function <- function(fishery_dir, region){
  # load the fishery raster data
  region_data <- terra::rast(file.path(data_dir, fishery_dir, "w001001.adf"))
  
  # limit fishery raster data to the study region
  raster <- terra::crop(x = region_data,
                        # crop using study region
                        y = region,
                        # mask using study region (T = True)
                        mask = T,
                        extend = T)
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
region <- region <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_rm_constraints_boundary_{date}")) %>%
  # change projection to match VMS data coordinate reference system
  sf::st_transform(crs = data_crs)

### Inspect study region coordinate reference system
cat(crs(region))

## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_rm_constraints_{date}"))

#####################################
#####################################

# run z-membership function on each fishery
## 2015 - 2016 fishery data for speeds under 4 / 5 knots
### herring
her_4kt <- fishery_function("her_15_16_4kt", region)

### monk fish
mnk_4kt <- fishery_function("mnk_15_16_4kt", region)

### multiple species
nms_4kt <- fishery_function("nms_15_16_4kt", region)

### pelagics
pel_4kt <- fishery_function("pel_15_16_4kt", region)

### surfclam / quahog
sco_4kt <- fishery_function("sco_15_16_4kt", region)

### scallops
ses_5kt <- fishery_function("ses_15_16_5kt", region)

### squid
smb_4kt <- fishery_function("smb_15_16_4kt", region)

#####################################

# Inspect data
her_4kt
mnk_4kt
nms_4kt
pel_4kt
sco_4kt
ses_5kt
smb_4kt

## dimensions and update for those that are different
### ***warning: the calculation of the mean across the fisheries
###             will not work properly if the dimensions across
###             all the datasets are not uniform (273 x 454)
dim(her_4kt) # 204 x 350
dim(mnk_4kt) # 205 x 350
dim(nms_4kt) # 205 x 350
dim(pel_4kt) # 204 x 350
dim(sco_4kt) # 204 x 350
dim(ses_5kt) # 204 x 350
dim(smb_4kt) # 204 x 351

### force the correct extent for ones with different extents
her_4kt_2 <- terra::extend(x = her_4kt,
                           # extend to match largest extent
                           y = smb_4kt)
mnk_4kt_2 <- terra::extend(x = mnk_4kt,
                           # extend to match largest extent
                           y = smb_4kt)
nms_4kt_2 <- terra::extend(x = nms_4kt,
                           # extend to match largest extent
                           y = smb_4kt)
pel_4kt_2 <- terra::extend(x = pel_4kt,
                           # extend to match largest extent
                           y = smb_4kt)
pel_4kt_3 <- terra::extend(x = pel_4kt,
                           # extend to match largest extent
                           y = her_4kt_2)
sco_4kt_2 <- terra::extend(x = sco_4kt,
                           # extend to match largest extent
                           y = smb_4kt)
ses_5kt_2 <- terra::extend(x = ses_5kt,
                           # extend to match largest extent
                           y = smb_4kt)
ses_5kt_3 <- terra::extend(x = ses_5kt_2,
                           # extend to match largest extent
                           y = her_4kt)
smb_4kt_2 <- terra::extend(x = smb_4kt,
                           # extend to match largest extent
                           y = her_4kt)

dim(her_4kt_2) # 205 x 351
dim(mnk_4kt_2) # 205 x 351
dim(nms_4kt_2) # 205 x 351
dim(pel_4kt_2) # 204 x 351
dim(pel_4kt_3) # 205 x 351
dim(sco_4kt_2) # 205 x 351
dim(ses_5kt_2) # 204 x 351
dim(ses_5kt_3) # 204 x 351
dim(smb_4kt_2) # 205 x 351

## plot data
plot(her_4kt_2)
plot(mnk_4kt_2)
plot(nms_4kt_2)
plot(pel_4kt_3)
plot(sco_4kt_2)
plot(ses_5kt_3)
plot(smb_4kt_2)

#####################################

## extents
### ***warning: the calculation of the mean across the fisheries
###             will not work properly if the extensions across
###             all the datasets are not uniform
terra::ext(her_4kt_2)
terra::ext(mnk_4kt_2)
terra::ext(nms_4kt_2)
terra::ext(pel_4kt_3)
terra::ext(sco_4kt_2)
terra::ext(ses_5kt_3)
terra::ext(smb_4kt_2)

### expand extent
#### ***note: this will take the maximum possible extent
####          across all the fishery datasets
xmin <- min(terra::ext(her_4kt_2)[1],
            terra::ext(mnk_4kt_2)[1],
            terra::ext(nms_4kt_2)[1],
            terra::ext(pel_4kt_3)[1],
            terra::ext(sco_4kt_2)[1],
            terra::ext(ses_5kt_3)[1],
            terra::ext(smb_4kt_2)[1])
xmin

xmax <- max(terra::ext(her_4kt_2)[2],
            terra::ext(mnk_4kt_2)[2],
            terra::ext(nms_4kt_2)[2],
            terra::ext(pel_4kt_3)[2],
            terra::ext(sco_4kt_2)[2],
            terra::ext(ses_5kt_3)[2],
            terra::ext(smb_4kt_2)[2])
xmax

ymin <- min(terra::ext(her_4kt_2)[3],
            terra::ext(mnk_4kt_2)[3],
            terra::ext(nms_4kt_2)[3],
            terra::ext(pel_4kt_3)[3],
            terra::ext(sco_4kt_2)[3],
            terra::ext(ses_5kt_3)[3],
            terra::ext(smb_4kt_2)[3])
ymin

ymax <- max(ext(her_4kt_2)[4],
            ext(mnk_4kt_2)[4],
            ext(nms_4kt_2)[4],
            ext(pel_4kt_3)[4],
            ext(sco_4kt_2)[4],
            ext(ses_5kt_3)[4],
            ext(smb_4kt_2)[4])
ymax

### raster extent
raster_ext <- c(xmin, xmax, ymin, ymax)

terra::ext(her_4kt_2) <- raster_ext
terra::ext(mnk_4kt_2) <- raster_ext
terra::ext(nms_4kt_2) <- raster_ext
terra::ext(pel_4kt_3) <- raster_ext
terra::ext(sco_4kt_2) <- raster_ext
terra::ext(ses_5kt_3) <- raster_ext
terra::ext(smb_4kt_2) <- raster_ext

#####################################

## reinspect data
her_4kt_2
mnk_4kt_2
nms_4kt_2
pel_4kt_3
sco_4kt_2
ses_5kt_3
smb_4kt_2

#####################################
#####################################

# combine all fishery rasters
## ***warning: verify that all rasters have exact same
##             dimensions and extents before running
region_data <- terra::app(c(her_4kt_2,
                            mnk_4kt_2,
                            nms_4kt_2,
                            pel_4kt_3,
                            sco_4kt_2,
                            ses_5kt_3,
                            smb_4kt_2),
                          # take mean values of fishery under 4 / 5 knots rasters (2015 - 2016)
                          fun = mean,
                          # remove any NA values from mean calculation
                          na.rm = T) %>%
  
  # crop and mask to the study region
  terra::crop(region,
              mask = T)

terra::minmax(region_data)[1]
terra::minmax(region_data)[2]

#####################################
#####################################

# rescale using z-membership function
region_data_z <- region_data %>%
  
  # apply the z-membership function
  zmf_function()

terra::minmax(region_data_z)[1]
terra::minmax(region_data_z)[2]

#####################################
#####################################

# convert raster to vector data (as polygons)
# convert to polygon
region_data_polygon <- terra::as.polygons(x = region_data_z,
                                          # do not aggregate all similar values together as single feature
                                          aggregate = F,
                                          # use the values from original raster
                                          values = T) %>%
  # change to simple feature (sf)
  sf::st_as_sf() %>%
  # simplify column name to "vms" (this is the first column of the object, thus the colnames(.)[1] means take the first column name from the vms object)
  dplyr::rename(vms = colnames(.)[1]) %>%
  # add field "layer" and populate with "vms"
  dplyr::mutate(layer = "vms") %>%
  # limit to the study region
  rmapshaper::ms_clip(clip = region) %>%
  # reproject data into a coordinate system (NAD 1983 UTM Zone 18N) that will convert units from degrees to meters
  sf::st_transform(crs = crs)

## inspect vectorized rescaled VMS data (***warning: lots of data, so will take a long time to load; comment out unless want to display data)
# plot(region_data_polygon)

#####################################
#####################################

# vessel trip reporting hex grids
region_data_hex <- hex_grid[region_data_polygon, ] %>%
  # spatially join vessel trip reporting values to Westport hex cells
  sf::st_join(x = .,
              y = region_data_polygon,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(index, layer,
                vms) %>%
  # group by the index values as there are duplicates
  dplyr::group_by(index) %>%
  # summarise the fisheries score values
  ## take the maximum value of the VMS score for any that overlap
  dplyr::summarise(vms_kt_max = max(vms))

test <- region_data_hex %>%
  sf::st_drop_geometry()

has_na <- rownames(test)[!complete.cases(test)]

plot(region_data_hex$geom)

#####################################
#####################################

# export data
## fisheries geopackage
sf::st_write(obj = region_data_hex, dsn = submodel, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## vms geopackage
sf::st_write(obj = region_data_polygon, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_polygon_{date}"), append = F)
sf::st_write(obj = region_data_hex, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## vms raster
vms_raster <- dir.create(paste0("data/b_intermediate_data/vms_data"))
raster_dir <- "data/b_intermediate_data/vms_data"

### fishery rasters
terra::writeRaster(her_4kt, filename = file.path(raster_dir, stringr::str_glue("{region_name}_herring_2015_2016_4kt.grd")), overwrite = T)
terra::writeRaster(mnk_4kt, filename = file.path(raster_dir, stringr::str_glue("{region_name}_monk_fish_2015_2016_4kt.grd")), overwrite = T)
terra::writeRaster(nms_4kt, filename = file.path(raster_dir, stringr::str_glue("{region_name}_multiple_species_2015_2016_4kt.grd")), overwrite = T)
terra::writeRaster(pel_4kt, filename = file.path(raster_dir, stringr::str_glue("{region_name}_pelagics_2015_2016_4kt.grd")), overwrite = T)
terra::writeRaster(sco_4kt, filename = file.path(raster_dir, stringr::str_glue("{region_name}_surfclam_quahog_2015_2016_4kt.grd")), overwrite = T)
terra::writeRaster(ses_5kt, filename = file.path(raster_dir, stringr::str_glue("{region_name}_scallop_2015_2016_5kt.grd")), overwrite = T)
terra::writeRaster(smb_4kt, filename = file.path(raster_dir, stringr::str_glue("{region_name}_squid_2015_2016_4kt.grd")), overwrite = T)

terra::writeRaster(region_data, filename = file.path(raster_dir, stringr::str_glue("{region_name}_fishery_4_5kt.grd")), overwrite = T)
terra::writeRaster(region_data_z, filename = file.path(raster_dir, stringr::str_glue("{region_name}_4_5kt_rescaled.grd")), overwrite = T)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
