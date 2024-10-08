#########################################################
### 21. Vessel trip reporting (VTR) -- all gear types ###
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

# set parameters
## designate region name
region_name <- "westport"

## coordinate reference system
### EPSG:26918 is NAD83 / UTM 18N (https://epsg.io/26918)
crs <- "EPSG:26918"

### EPSG:26919 is NAD83 / UTM 19N (https://epsg.io/26919)
data_crs <- "EPSG:26919"

## layer names
layer_name <- "vtr_all_gear"

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
data_dir <- "data/a_raw_data/VTR_allGearTypes/"

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
## z-membership function
### Adapted from https://www.mathworks.com/help/fuzzy/zmf.html
zmf_function <- function(raster){
  
  # calculate minimum value
  min <- terra::minmax(raster)[1,]
  
  # calculate maximum value
  max <- terra::minmax(raster)[2,]
  
  # calculate z-score minimum value
  ## this ensures that no value gets a value of 0
  z_max <- max + (max * 1 / 1000)
  
  # calculate z-scores (more desired values get score of 1 while less desired will decrease till 0)
  z_value <- ifelse(raster[] == min, 1, # if value is equal to minimum, score as 1
                    # if value is larger than minimum but lower than mid-value, calculate based on reduction equation
                    ifelse(raster[] > min & raster[] < (min + z_max) / 2, 1 - 2 * ((raster[] - min) / (z_max - min)) ** 2,
                           # if value is larger than mid-value but lower than maximum, calculate based on equation
                           ifelse(raster[] >= (min + z_max) / 2 & raster[] < z_max, 2*((raster[] - z_max) / (z_max - min)) ** 2,
                                  # if value is equal to maximum, score min - (min * 1 / 1000); otherwise give NA
                                  ifelse(raster[] == z_max, 0, NA))))
  
  # set values back to the original raster
  zvalues <- terra::setValues(raster, z_value)
  plot(zvalues)
  
  # return the raster
  return(zvalues)
}

#####################################
#####################################

# load data
## VTR (all gear types)
data <- terra::rast(file.path(data_dir, "VTR_allGearTypes"))

## study region
region <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area")) %>%
  # change projection to match AIS data coordinate reference system
  sf::st_transform(crs = data_crs)

### Inspect study region coordinate reference system
cat(crs(region))

## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area_hex"))

#####################################
#####################################

# limit VTR (all gear types) data to study region
region_data <- terra::crop(x = data,
                           # crop using study region
                           y = region,
                           # mask using study region (T = True)
                           mask = T,
                           extend = T)
plot(region_data)

#####################################
#####################################

# rescale using z-membership function
region_data_z <- region_data %>%
  # apply the z-membership function
  zmf_function()

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
  # simplify column name to "vtr" (this is the first column of the object, thus the colnames(.)[1] means take the first column name from the vtr object)
  dplyr::rename(vtr = colnames(.)[1]) %>%
  # add field "layer" and populate with "vms"
  dplyr::mutate(layer = "vtr") %>%
  # limit to the study region
  rmapshaper::ms_clip(clip = region) %>%
  # reproject data into a coordinate system (NAD 1983 UTM Zone 18N) that will convert units from degrees to meters
  sf::st_transform(crs = crs)

## inspect vectorized rescaled vtr data (***warning: lots of data, so will take a long time to load; comment out unless want to display data)
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
                vtr) %>%
  # group by the index values as there are duplicates
  dplyr::group_by(index) %>%
  # summarise the fisheries score values
  ## take the maximum value of the AIS score for any that overlap
  ## ***Note: this will provide the most conservation given that
  ##          high values are less desirable
  dplyr::summarise(vtr_max = max(vtr))

#####################################
#####################################

# export data
## fisheries geopackage
sf::st_write(obj = region_data_hex, dsn = submodel, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## vtr geopackage
sf::st_write(obj = region_data_polygon, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_polygon_{date}"), append = F)
sf::st_write(obj = region_data_hex, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## vtr raster
vtr_raster <- dir.create(paste0("data/b_intermediate_data/vtr_data"))
raster_dir <- "data/b_intermediate_data/vtr_data"

terra::writeRaster(data, filename = file.path(raster_dir, stringr::str_glue("{layer_name}.grd")), overwrite = T)
terra::writeRaster(region_data, filename = file.path(raster_dir, stringr::str_glue("{region_name}_{layer_name}.grd")), overwrite = T)
terra::writeRaster(region_data_z, filename = file.path(raster_dir, stringr::str_glue("{region_name}_{layer_name}_rescaled.grd")), overwrite = T)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
