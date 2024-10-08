#########################
### 2. Federal waters ###
#########################

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

## layer names
layer_name <- "federal_waters"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### federal waters
data_dir <- "data/a_raw_data/CoastalZoneManagementAct/CoastalZoneManagementAct.gpkg"

#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

### output directories
#### constraints
constraints_gpkg <- "data/c_submodel_data/constraints.gpkg"

#### intermediate directories
output_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_{layer_name}.gpkg")

#####################################

# inspect layers within geopackages
sf::st_layers(dsn = data_dir,
              do_count = T)

sf::st_layers(dsn = region_gpkg,
              do_count = T)

#####################################
#####################################

# load data
## federal waters data (source: https://marinecadastre.gov/downloads/data/mc/CoastalZoneManagementAct.zip)
### metadata: https://www.fisheries.noaa.gov/inport/item/53132
federal_waters <- sf::st_read(dsn = data_dir,
                              layer = sf::st_layers(data_dir)[[1]]) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs) %>%
  # get only federal waters
  dplyr::filter(CZMADomain == "federal consistency") %>%
  dplyr::group_by(CZMADomain) %>%
  dplyr::summarise()

#####################################
#####################################

# export data
## constraints geopackage
sf::st_write(obj = federal_waters, dsn = constraints_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)
sf::st_write(obj = federal_waters, dsn = region_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

## federal waters geopackage
sf::st_write(obj = federal_waters, dsn = datagpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
