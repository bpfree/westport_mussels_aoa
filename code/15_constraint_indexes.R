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
                                                                        x = sf::st_layers(dsn = submodel_gpkg)[[1]])]) %>%
  dplyr::select(index)

### danger zones
danger_zones <- sf::st_read(dsn = submodel_gpkg,
                   layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("{region_name}_hex_danger_zones_restricted_areas_{date}"),
                                                                        x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
  dplyr::select(index)

### environmental sensors
environmental_sensor <- sf::st_read(dsn = submodel_gpkg,
                            layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("{region_name}_hex_environmental_sensor_{date}"),
                                                                                 x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
  dplyr::select(index)

# ### wastewater outfalls
# ww_outfalls <- sf::st_read(dsn = submodel_gpkg,
#                             layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("outfalls_{date}"),
#                                                                                  x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
#   dplyr::select(index)
# 
# ### ocean disposal
# ocean_disposal <- sf::st_read(dsn = submodel_gpkg,
#                             layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("disposal_{date}"),
#                                                                                  x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
#   dplyr::select(index)

### aids to navigation
aids_navigation <- sf::st_read(dsn = submodel_gpkg,
                            layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("navigation_{date}"),
                                                                                 x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
  dplyr::select(index)

### wrecks and obstructions
wreck_obstruction <- sf::st_read(dsn = submodel_gpkg,
                            layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("obstruction_{date}"),
                                                                                 x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
  dplyr::select(index)

### shipping fairways
shipping_fairways <- sf::st_read(dsn = submodel_gpkg,
                            layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("fairway_{date}"),
                                                                                 x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
  dplyr::select(index)

### proposed offshore wind cable corridors
cable_corridors <- sf::st_read(dsn = submodel_gpkg,
                                 layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("corridors_{date}"),
                                                                                      x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
  dplyr::select(index)

### offshore wind areas
offshore_wind <- sf::st_read(dsn = submodel_gpkg,
                                 layer = sf::st_layers(dsn = submodel_gpkg)[[1]][grep(pattern = stringr::str_glue("wind_{date}"),
                                                                                      x = sf::st_layers(dsn = submodel_gpkg)[[1]])])%>%
  dplyr::select(index)

#####################################

## study region
region <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area"))

## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area_hex"))

#####################################
#####################################

# create hex grid of just constraint hexes
hex_constraint <- rbind(mec,
                        danger_zones,
                        environmental_sensor,
                        aids_navigation,
                        wreck_obstruction,
                        shipping_fairways,
                        cable_corridors,
                        offshore_wind) %>%
  dplyr::group_by(index) %>%
  dplyr::summarise() %>%
  dplyr::mutate(submodel = "constraint")

# generate list of indexes that are constraints
hex_constraint_list <- as.vector(hex_constraint$index)

#####################################
#####################################

hex_grid_rm_constraints <- hex_grid %>%
  dplyr::filter(!index %in% constraint_hex_list)

# create a dissolved grid
dissolved_grid <- hex_grid_rm_constraints %>%
  # create new field to designate region
  dplyr::mutate(region = "westport") %>%
  # group by region
  dplyr::group_by(region) %>%
  # summarise by region to dissolve to one polygon
  dplyr::summarise()

#####################################
#####################################

# export data
## submodel geopackage
sf::st_write(obj = hex_constraint, dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_{submodel}_{date}"), append = F)
sf::st_write(obj = hex_grid_rm_constraints, dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_rm_{submodel}_{date}"), append = F)
sf::st_write(obj = dissolved_grid, dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_rm_{submodel}_boundary_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
