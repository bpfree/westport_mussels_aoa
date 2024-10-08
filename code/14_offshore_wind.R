######################################
### 14. Offshore wind energy areas ###
######################################

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
layer_name <- "offshore_wind"

## submodel
submodel <- "constraints"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### offshore wind energy areas
data_dir <- "data/a_raw_data/BOEM-Renewable-Energy-Geodatabase/BOEMWindLayers_4Download.gdb"

#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

### output directories
#### submodel
submodel_gpkg <- stringr::str_glue("data/c_submodel_data/{submodel}.gpkg")

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
## offshore wind areas (source: https://www.boem.gov/renewable-energy/boem-renewable-energy-geodatabase)
### metadata: https://www.arcgis.com/sharing/rest/content/items/709831444a234968966667d84bcc0357/info/metadata/metadata.xml?format=default&output=html
data <- sf::st_read(dsn = data_dir,
                             layer = sf::st_layers(data_dir)[[1]][grep(pattern = "Wind_Leases",
                                                                       x = sf::st_layers(dsn = data_dir)[[1]])]) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs)

#####################################

## study region
region <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area"))

## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area_hex"))

#####################################
#####################################

# limit data to study region
region_data <- data %>%
  # obtain only offshore wind in the study area
  rmapshaper::ms_clip(target = .,
                      clip = region) %>%
  # create field called "layer" and fill with "offshore wind" for summary
  dplyr::mutate(layer = "offshore wind")

#####################################
#####################################

# offshore wind hex grids
region_data_hex <- hex_grid[region_data, ] %>%
  # spatially join offshore wind values to Westport hex cells
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
sf::st_write(obj = data, dsn = output_gpkg, layer = stringr::str_glue("{layer_name}_{date}"), append = F)
sf::st_write(obj = region_data, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
