####################################
### 2. Unexploded ordnance areas ###
####################################

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

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### unexploded ordnance
uxo_areas_gdb <- "data/a_raw_data/UnexplodedOrdnanceArea/UnexplodedOrdnanceArea.gdb"
uxo_locations_gdb <- "data/a_raw_data/UnexplodedOrdnance/UnexplodedOrdnance.gdb"

#### study area grid
study_region_gpkg <- "data/b_intermediate_data/westport_study_area.gpkg"

### output directories
#### constraints
constraints_gpkg <- "data/c_submodel_data/constraints.gpkg"

#### intermediate directories
uxo_gpkg <- "data/b_intermediate_data/westport_unexploded_ordnance.gpkg"

#####################################

# inspect layers within geodatabases and geopackages
sf::st_layers(dsn = uxo_areas_gdb,
              do_count = T)
sf::st_layers(dsn = uxo_locations_gdb,
              do_count = T)

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

## Unexploded ordnance types of interest
uxo_types <- c("JATO Racks and Associated Debris", "Unexploded Depth Bombs")

## setback distance (in meters)
setback <- 500

## layer names
export_name <- "uxo"
export_area <- "uxo_area"
export_location <- "uxo_location"

## designate date
date <- format(Sys.time(), "%Y%m%d")

#####################################
#####################################

# load data
## unexploded ordnance area data (source: https://marinecadastre.gov/downloads/data/mc/UnexplodedOrdnance.zip)
### metadata: https://www.fisheries.noaa.gov/inport/item/66208
### ***Note: the location geodatabase has 1 more feature for the areas
###          object than the areas geodatabase, hence why it is use
uxo_areas <- sf::st_read(dsn = uxo_locations_gdb, layer = "UnexplodedOrdnanceAreas") %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs)

## unexploded ordnance location data (source: https://marinecadastre.gov/downloads/data/mc/UnexplodedOrdnance.zip)
### metadata: https://www.fisheries.noaa.gov/inport/item/66208
uxo_locations <- sf::st_read(dsn = uxo_locations_gdb, layer = "UnexplodedOrdnanceLocations") %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs) %>%
  # apply 500-meter setback
  sf::st_buffer(x = ., dist = setback)

#####################################

## study region
westport_region <- sf::st_read(dsn = study_region_gpkg, layer = paste(region, "area", sep = "_"))

## hex grid
westport_hex <- sf::st_read(dsn = study_region_gpkg, layer = paste(region, "area_hex", sep = "_"))

#####################################
#####################################

# limit data to study region
westport_uxo_areas <- uxo_areas %>%
  # obtain only unexploded ordnance areas in the study area
  rmapshaper::ms_clip(target = .,
                      clip = westport_region) %>%
  # filter for only types of interest
  # dplyr::filter(name %in% uxo_types)
  # create field called "layer" and fill with "unexploded ordnance" for summary
  dplyr::mutate(layer = "unexploded ordnance") %>%
  dplyr::select(name, layer)

westport_uxo_locations <- uxo_locations %>%
  # obtain only unexploded ordnance areas in the study area
  rmapshaper::ms_clip(target = .,
                      clip = westport_region) %>%
  # filter for only types of interest
  # dplyr::filter(name %in% uxo_types)
  # create field called "layer" and fill with "unexploded ordnance" for summary
  dplyr::mutate(layer = "unexploded ordnance") %>%
  dplyr::select(name, layer)

#####################################

westport_uxo <- rbind(westport_uxo_areas,
                      westport_uxo_locations)

#####################################
#####################################

# unexploded ordnance hex grids
westport_uxo_hex <- westport_hex[westport_uxo, ] %>%
  # spatially join unexploded ordnance values to Westport hex cells
  sf::st_join(x = .,
              y = westport_uxo,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(index, layer)

#####################################
#####################################

# export data
## constraints geopackage
sf::st_write(obj = westport_uxo_hex, dsn = constraints_gpkg, layer = paste(region, "hex", export_name, date, sep = "_"), append = F)

## unexploded ordnance geopackage
sf::st_write(obj = uxo_areas, dsn = uxo_gpkg, layer = paste(export_name, date, sep = "_"), append = F)
sf::st_write(obj = westport_uxo_areas, dsn = uxo_gpkg, layer = paste(region, export_area, date, sep = "_"), append = F)
sf::st_write(obj = westport_uxo_locations, dsn = uxo_gpkg, layer = paste(region, export_location, date, sep = "_"), append = F)
sf::st_write(obj = westport_uxo, dsn = uxo_gpkg, layer = paste(region, export_name, date, sep = "_"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
