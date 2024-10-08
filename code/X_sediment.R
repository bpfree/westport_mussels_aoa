####################
### 12. Sediment ###
####################

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
#### sediment
data_dir <- "data/a_raw_data/SedimentTexture/SedimentTexture.gpkg"

#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

### output directories
#### natural and cultural resources
natural_cultural_gpkg <- "data/c_submodel_data/natural_cultural.gpkg"

#### intermediate directories
sediment_gpkg <- "data/b_intermediate_data/westport_sediment.gpkg"

#####################################

# inspect layers within geodatabases and geopackages
sf::st_layers(dsn = data_dir,
              do_count = T)

sf::st_layers(dsn = region_gpkg,
              do_count = T)

#####################################
#####################################

# set parameters
## designate region name
region_name <- "westport"

## coordinate reference system
### EPSG:26918 is NAD83 / UTM 18N (https://epsg.io/26918)
crs <- "EPSG:26918"

## layer names
layer_name <- "sediment"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# load data
## sediment data (source: https://marinecadastre.gov/downloads/data/mc/SedimentTexture.zip)
### metadata: https://www.fisheries.noaa.gov/inport/item/66197
sediment <- sf::st_read(dsn = data_dir,
                                    # sediment
                                    layer = sf::st_layers(data_dir)[[1]][1]) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs) %>%
  # limit to only classifications with either sand and / or mud
  dplyr::filter(grepl("Sand|Mud", classification, ignore.case = T))

list(unique(sediment$classification))
length(unique(sediment$classification)) # 238 different combinations that have either sand or mud

#####################################

## study region
region <- sf::st_read(dsn = region_gpkg, layer = paste(region, "area", sep = "_"))

## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = paste(region, "area_hex", sep = "_"))

#####################################
#####################################

# limit data to study region
westport_sediment <- sediment %>%
  # obtain only sediment in the study area
  rmapshaper::ms_clip(target = .,
                      clip = region) %>%
  # create field called "layer" and fill with "sediment" for summary
  dplyr::mutate(layer = "sediment")

#####################################
#####################################

# sediment hex grids
westport_sediment_hex <- hex_grid[westport_sediment, ] %>%
  # spatially join sediment values to Westport hex cells
  sf::st_join(x = .,
              y = westport_sediment,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(index, layer)

#####################################
#####################################

# export data
## constraints geopackage
sf::st_write(obj = westport_sediment_hex, dsn = natural_cultural_gpkg, layer = stringr::str_glue("{region}_hex_{layer_name}_{date}"), append = F)

## sediment geopackage
sf::st_write(obj = sediment, dsn = sediment_gpkg, layer = stringr::str_glue("{layer_name}_{date}"), append = F)
sf::st_write(obj = westport_sediment, dsn = sediment_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
