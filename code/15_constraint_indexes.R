###############################
### 15. Constraints indexes ###
###############################

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
               rgdal,
               rgeoda,
               rgeos,
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

# submodel
submodel <- "constraints"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

#### submodel
submodel_gpkg <- stringr::str_glue("data/c_submodel_data/{submodel}.gpkg")

#####################################

# inspect layers within geodatabases and geopackages
sf::st_layers(dsn = region_gpkg,
              do_count = T)

sf::st_layers(dsn = submodel_gpkg,
              do_count = T)

#####################################
#####################################

# load data
## constraints
### munitions and explosives of concern
mec <- sf::st_read(dsn = submodel_gpkg,
                   layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("{region_name}_hex_munitions_explosives_{date}"),
                                                                        x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

### danger zones
danger_zones <- sf::st_read(dsn = submodel_gpkg,
                   layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("{region_name}_hex_danger_zones_restricted_areas_{date}"),
                                                                        x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

### environmental sensors
environmental_sensor <- sf::st_read(dsn = submodel_gpkg,
                            layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("{region_name}_hex_environmental_sensor_{date}"),
                                                                                 x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

# ### wastewater outfalls
# ww_outfalls <- sf::st_read(dsn = submodel_gpkg,
#                             layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("outfalls_{date}"),
#                                                                                  x = sf::st_layers(dsn = submodel_gpkg)[[1]])])
# 
# ### ocean disposal
# ocean_disposal <- sf::st_read(dsn = submodel_gpkg,
#                             layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("disposal_{date}"),
#                                                                                  x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

### aids to navigation
aids_navigation <- sf::st_read(dsn = submodel_gpkg,
                            layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("navigation_{date}"),
                                                                                 x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

### wrecks and obstructions
wreck_obstruction <- sf::st_read(dsn = submodel_gpkg,
                            layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("obstruction_{date}"),
                                                                                 x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

### shipping fairways
shipping_fairways <- sf::st_read(dsn = submodel_gpkg,
                            layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("fairway_{date}"),
                                                                                 x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

### proposed offshore wind cable corridors
shipping_fairways <- sf::st_read(dsn = submodel_gpkg,
                                 layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("fairway_{date}"),
                                                                                      x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

### offshore wind areas
shipping_fairways <- sf::st_read(dsn = submodel_gpkg,
                                 layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("fairway_{date}"),
                                                                                      x = sf::st_layers(dsn = submodel_gpkg)[[1]])])

#####################################

## study region
region <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area"))

## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area_hex"))

#####################################
#####################################

# limit data to study region
region_data <- data %>%
  # obtain only shipping fairway in the study area
  rmapshaper::ms_clip(target = .,
                      clip = region) %>%
  # create field called "layer" and fill with "shipping fairway" for summary
  dplyr::mutate(layer = "shipping fairway")

#####################################
#####################################

# shipping fairway hex grids
region_data_hex <- hex_grid[region_data, ] %>%
  # spatially join shipping fairway values to Westport hex cells
  sf::st_join(x = .,
              y = region_data,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(index, layer) %>%
  # group by the index values as there are duplicates
  dplyr::group_by(index) %>%
  # summarise by index
  dplyr::summarise()

#####################################
#####################################

# export data
## submodel geopackage
sf::st_write(obj = region_data_hex, dsn = submodel_gpkg, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## data geopackage
sf::st_write(obj = data, dsn = output_gpkg, layer = stringr::str_glue("{layer_name}_{date}"), append = F)
sf::st_write(obj = region_data, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
