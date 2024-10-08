#############################
### 8. Wastewater outfall ###
#############################

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

## setback distance (in meters)
setback <- 500

## layer names
layer_name <- "wastewater_outfalls"
export_facility <- "wastewater_outfall_facility"
export_pipe <- "wastewater_outfall_pipe"
export_outfall <- "wastewater_outfall"

## submodel
submodel <- "constraints"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### wastewater outfall
data_dir <- "data/a_raw_data/WastewaterOutfall/WastewaterOutfall.gpkg"

#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

### output directories
#### submodel
submodel_gpkg <- stringr::str_glue("data/c_submodel_data/{submodel}.gpkg")

#### intermediate directories
output_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_{layer_name}.gpkg")

#####################################

# inspect layers within geodatabases and geopackages
sf::st_layers(dsn = data_dir,
              do_count = T)

sf::st_layers(dsn = region_gpkg,
              do_count = T)

#####################################
#####################################

# load data
## wastewater outfall data (source: https://marinecadastre.gov/downloads/data/mc/WastewaterOutfall.zip)
### ***note: data are comprised of three datasets: wastewater outfall facilities, wastewater outfall pipes, wastewater outfalls
### metadata: facilities --> https://www.fisheries.noaa.gov/inport/item/66706
###           pipes --> https://www.fisheries.noaa.gov/inport/item/66706
###           outfalls --> https://www.fisheries.noaa.gov/inport/item/66706
ww_facility <- sf::st_read(dsn = data_dir,
                           # wastewater facility
                           layer = sf::st_layers(data_dir)[[1]][1]) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs) %>%
  # apply 500-meter setback
  sf::st_buffer(x = ., dist = setback) %>%
  # select fields to keep same structure as other datasets
  dplyr::select(registryId) %>%
  st_as_sf()

ww_pipe <- sf::st_read(dsn = data_dir,
                           # wastewater pipe
                           layer = sf::st_layers(data_dir)[[1]][3]) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs) %>%
  # apply 500-meter setback
  sf::st_buffer(x = ., dist = setback)

ww_outfall <- sf::st_read(dsn = data_dir,
                           # wastewater outfall
                           layer = sf::st_layers(data_dir)[[1]][2]) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs) %>%
  # apply 500-meter setback
  sf::st_buffer(x = ., dist = setback)

#####################################

## study region
region <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area"))

## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area_hex"))

#####################################
#####################################

# limit data to study region
westport_ww_facility <- ww_facility %>%
  # obtain only wastewater outfall in the study area
  rmapshaper::ms_clip(target = .,
                      clip = region) %>%
  # create field called "layer" and fill with "wastewater facility" for summary
  dplyr::mutate(layer = "wastewater facility") %>%
  dplyr::select(layer)

westport_ww_pipe <- ww_pipe %>%
  # obtain only wastewater outfall in the study area
  rmapshaper::ms_clip(target = .,
                      clip = region) %>%
  # create field called "layer" and fill with "wastewater pipe" for summary
  dplyr::mutate(layer = "wastewater pipe") %>%
  dplyr::select(layer)

westport_ww_outfall <- ww_outfall %>%
  # obtain only wastewater outfall in the study area
  rmapshaper::ms_clip(target = .,
                      clip = region) %>%
  # create field called "layer" and fill with "wastewater outfall" for summary
  dplyr::mutate(layer = "wastewater outfall") %>%
  dplyr::select(layer)

#####################################

region_data <- rbind(westport_ww_facility,
                     westport_ww_pipe,
                     westport_ww_outfall)

#####################################
#####################################

# environmental sensor and buoys hex grids
region_data_hex <- hex_grid[region_data, ] %>%
  # spatially join wastewater outfall values to Westport hex cells
  sf::st_join(x = .,
              y = region_data,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(index, layer)

#####################################
#####################################

# export data
## submodel geopackage
sf::st_write(obj = region_data_hex, dsn = submodel_gpkg, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## data geopackage
sf::st_write(obj = ww_facility, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{export_facility}_{date}"), append = F)
sf::st_write(obj = ww_pipe, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{export_pipe}_{date}"), append = F)
sf::st_write(obj = ww_outfall, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{export_outfall}_{date}"), append = F)

sf::st_write(obj = region_data, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
