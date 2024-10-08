##############################
### 27. Fisheries submodel ###
##############################

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

## submodel
submodel <- "fisheries"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

## geometric mean weight
gm_wt <- 1/4

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

#### submodel geopackage
submodel_gpkg <- stringr::str("data/c_submodel_data/{submodel}.gpkg")

### submodel directory
suitability_dir <- "data/d_suitability_data"
dir.create(paste0(suitability_dir, "/",
                  stringr::str_glue("{submodel}_suitability")))

suitability_dir <- stringr::str_glue("data/d_suitability_data/{submodel}_suitability")
submodel_suitability_gpkg <- stringr::str_glue("data/d_suitability_data/{submodel}_suitability/{region_name}_{submodel}_suitability.gpkg")

#### suitability
suitability_gpkg <- "data/d_suitability_data/suitability.gpkg"

#####################################

# inspect layers within geopackage
sf::st_layers(dsn = region_gpkg,
              do_count = T)

sf::st_layers(dsn = submodel_gpkg,
              do_count = T)

#####################################
#####################################

# load data
## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_area_hex"))

## submodel datasets
### VMS (all gear, 2015 - 2016)
hex_grid_vms_all <- sf::st_read(dsn = submodel_gpkg, layer = paste(region, "hex", "vms_all", date, sep = "_")) %>%
  sf::st_drop_geometry()

### VMS (speeds under 4 / 5 knots, 2015 - 2016)
hex_grid_vms_4_5_knot <- sf::st_read(dsn = submodel_gpkg, layer = paste(region, "hex", "vms_4_5_knot", date, sep = "_")) %>%
  sf::st_drop_geometry()

### VTR (all gear types)
hex_grid_vtr <- sf::st_read(dsn = submodel_gpkg, layer = paste(region, "hex", "vtr_all_gear", date, sep = "_")) %>%
  sf::st_drop_geometry()

### large pelagic survey
hex_grid_lps <- sf::st_read(dsn = submodel_gpkg, layer = paste(region, "hex", "large_pelagic_survey", date, sep = "_")) %>%
  sf::st_drop_geometry()

#####################################
#####################################

# Create Oregon constraints submodel
hex_grid_fisheries <- hex_grid %>%
  dplyr::left_join(x = .,
                   y = hex_grid_vms_all,
                   by = "index") %>%
  dplyr::left_join(x = .,
                   y = hex_grid_vms_4_5_knot,
                   by = "index") %>%
  dplyr::left_join(x = .,
                   y = hex_grid_vtr,
                   by = "index") %>%
  dplyr::left_join(x = .,
                   y = hex_grid_lps,
                   by = "index") %>%
  dplyr::select(index,
                contains("max")) %>%
  
  # add value of 1 for datasets when hex cell has value of NA
  ## for hex cells not impacted by a particular dataset, that cell gets a value of 1
  ### this indicates  suitability with wind energy development
  dplyr::mutate(across(2:5, ~replace(x = .,
                                     list = is.na(.),
                                     # replacement values
                                     values = 1))) %>%
  
  ## geometric mean = nth root of the product of the variable values
  dplyr::mutate(fish_geom_mean = (vms_all_max ^ gm_wt) * (vms_kt_max ^ gm_wt) * (vtr_max ^ gm_wt) * (lps_max * gm_wt)) %>%
  
  # relocate the industry and operations geometric mean field
  dplyr::relocate(fish_geom_mean,
                  .after = lps_max)

### ***Warning: there are duplicates of the index
duplicates_verify <- hex_grid_fisheries %>%
  # create frequency field based on index
  dplyr::add_count(index) %>%
  # see which ones are duplicates
  dplyr::filter(n>1) %>%
  # show distinct options
  dplyr::distinct()

#####################################
#####################################

# Export data
## suitability
sf::st_write(obj = hex_grid_fisheries, dsn = suitability_gpkg, layer = paste(region, submodel, "suitability", sep = "_"), append = F)

## fisheries
saveRDS(obj = hex_grid_vms_all, file = paste(fisheries_dir, paste(region, "hex_fisheries_vms_all.rds", sep = "_"), sep = "/"))
saveRDS(obj = hex_grid_vms_4_5_knot, file = paste(fisheries_dir, paste(region, "hex_fisheries_vms_4_5_kt.rds", sep = "_"), sep = "/"))
saveRDS(obj = hex_grid_vtr, file = paste(fisheries_dir, paste(region, "hex_fisheries_vtr.rds", sep = "_"), sep = "/"))
saveRDS(obj = hex_grid_lps, file = paste(fisheries_dir, paste(region, "hex_fisheries_lps.rds", sep = "_"), sep = "/"))

sf::st_write(obj = hex_grid_fisheries, dsn = fisheries_gpkg, layer = paste(region, "hex", submodel, "suitability", sep = "_"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
