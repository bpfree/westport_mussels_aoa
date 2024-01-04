#######################################
### X. Combined protected resources ###
#######################################

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
#### combined protected resources
data_dir <- "data/a_raw_data/combined_protected_resources"

#### study area grid
study_region_gpkg <- "data/b_intermediate_data/westport_study_area.gpkg"

### output directories
#### fisheries
fisheries_gpkg <- "data/c_submodel_data/fisheries.gpkg"

#### intermediate directories
comb_prot_resources_gpkg <- "data/b_intermediate_data/westport_combined_protected_resources.gpkg"

#####################################

# inspect layers within geopackage
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

## layer names
export_name <- "large_pelagic_survey"

## designate date
date <- format(Sys.time(), "%Y%m%d")

#####################################
#####################################

# load data
## combined protected resources data
comb_prot_resources <- sf::st_read(dsn = file.path(paste(data_dir, "final_PRD_CEATL_WP.shp", sep = "/"))) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs)

#####################################

## study region
westport_region <- sf::st_read(dsn = study_region_gpkg, layer = paste(region, "area", sep = "_"))

## hex grid
westport_hex <- sf::st_read(dsn = study_region_gpkg, layer = paste(region, "area_hex", sep = "_"))

#####################################
#####################################

# limit data to study region
westport_comb_prot_resources <- comb_prot_resources %>%
  # obtain only combined protected resources in the study area
  rmapshaper::ms_clip(target = .,
                      clip = westport_region) %>%
  # create field called "layer" and fill with "combined protected resources" for summary
  dplyr::mutate(layer = "combined protected resources")

#####################################
#####################################

# combined protected resources hex grids
westport_comb_prot_resources_hex <- westport_hex[westport_comb_prot_resources, ] %>%
  # spatially join combined protected resources values to Westport hex cells
  sf::st_join(x = .,
              y = westport_comb_prot_resources,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(index, layer)

#####################################
#####################################

# export data
## constraints geopackage
sf::st_write(obj = westport_comb_prot_resources_hex, dsn = fisheries_gpkg, layer = paste(region, "hex", export_name, date, sep = "_"), append = F)

## combined protected resources geopackage
sf::st_write(obj = comb_prot_resources, dsn = comb_prot_resources_gpkg, layer = paste(export_name, date, sep = "_"), append = F)
sf::st_write(obj = westport_comb_prot_resources, dsn = comb_prot_resources_gpkg, layer = paste(region, export_name, date, sep = "_"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
