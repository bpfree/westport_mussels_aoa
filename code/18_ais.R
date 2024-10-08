#################################################
### 18. Automatic identification system (AIS) ###
#################################################

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

### EPSG:3857 is WGS 84 / Pseudo-Mercator -- Spherical Mercator, Google Maps, OpenStreetMap, Bing, ArcGIS, ESRI (https://epsg.io/3857)
data_crs <- "EPSG:3857"

## layer names
layer_name <- "ais"

## submodel
submodel <- "industry"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### vessel trip reporting
data_dir <- "data/a_raw_data/ais_2022/ais_2022_year"

#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

### output directories
#### industry, transportation, navigation
submodel_gpkg <- stringr::str_glue("data/c_submodel_data/{submodel}.gpkg")

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
  
  # return the raster
  return(zvalues)
}

#####################################
#####################################

# load data
## AIS 2022 data (source: https://services.northeastoceandata.org/downloads/AIS/AIS2022_Annual.zip)
### metadata: https://www.northeastoceandata.org/files/metadata/Themes/AIS/AllAISVesselTransitCounts2022.pdf
data <- terra::rast(file.path(data_dir, "w001001.adf"))
crs(data) <- data_crs

### inspect data
#### plot data
plot(data)

#### minimum and maximum values
terra::minmax(data)[1]
terra::minmax(data)[2]

### coordinate reference system
cat(crs(data))

#####################################

## study region
region <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_rm_constraints_boundary_{date}")) %>%
  # change projection to match AIS data coordinate reference system
  sf::st_transform(crs = data_crs)

### Inspect study region coordinate reference system
cat(crs(region))

## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_rm_constraints_{date}"))

#####################################
#####################################

plot(region)

# limit data to study region
region_data <- terra::crop(x = data,
                           # crop using study region
                           y = region,
                           # mask using study region (T = True)
                           mask = T)

plot(region_data)

#####################################
#####################################

# rescale AIS values using a z-membership function
region_data_z <- region_data %>%
  zmf_function()

## inspect rescaled data
plot(region_data_z)

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
  # simplify column name to "ais" (this is the first column of the object, thus the colnames(.)[1] means take the first column name from the ais object)
  dplyr::rename(ais = colnames(.)[1]) %>%
  # add field "layer" and populate with "ais"
  dplyr::mutate(layer = "ais") %>%
  # limit to the study region
  rmapshaper::ms_clip(clip = region) %>%
  # reproject data into a coordinate system (NAD 1983 UTM Zone 18N) that will convert units from degrees to meters
  sf::st_transform(crs = crs)

## inspect vectorized rescaled AIS data (***warning: lots of data, so will take a long time to load; comment out unless want to display data)
# plot(westport_ais_polygon)

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
                ais) %>%
  # group by the index values as there are duplicates
  dplyr::group_by(index) %>%
  # summarise the fisheries score values
  ## take the maximum value of the AIS score for any that overlap
  ## ***Note: this will provide the most conservation given that
  ##          high values are less desirable
  dplyr::summarise(ais_max = max(ais))

#####################################
#####################################

# export data
## industry, transportation, navigation geopackage
sf::st_write(obj = region_data_hex, dsn = submodel_gpkg, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## ais geopackage
sf::st_write(obj = region_data_polygon, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_polygon_{date}"), append = F)
sf::st_write(obj = region_data_hex, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## ais raster
ais_raster <- dir.create(paste0("data/b_intermediate_data/ais_data"))
raster_dir <- "data/b_intermediate_data/ais_data"

terra::writeRaster(region_data, filename = file.path(raster_dir, stringr::str_glue("{region_name}_{layer_name}_2022.grd")), overwrite = T)
terra::writeRaster(data, filename = file.path(raster_dir, stringr::str_glue("{layer_name}_2022.grd")), overwrite = T)
terra::writeRaster(region_data_z, filename = file.path(raster_dir, stringr::str_glue("{region_name}_{layer_name}_2022_rescaled.grd")), overwrite = T)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
