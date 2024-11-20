############################################
### 33. Suitability model -- without PRD ###
############################################

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

## submodel name
industry <- "industry"
itn_code <- "itn"

fish <- "fisheries"
fish_code <- "fish"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

## geometric mean weight
gm_wt <- 1/5

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

#### submodel geopackage
industry_gpkg <- stringr::str_glue("data/c_submodel_data/{industry}.gpkg")
fisheries_gpkg <- stringr::str_glue("data/c_submodel_data/{fish}.gpkg")

#### suitability geopackage
suitability_gpkg <- "data/d_suitability_data/suitability.gpkg"

#####################################

# inspect layers within geopackage
sf::st_layers(dsn = region_gpkg,
              do_count = T)

sf::st_layers(dsn = industry_gpkg,
              do_count = T)

sf::st_layers(dsn = fisheries_gpkg,
              do_count = T)

sf::st_layers(dsn = suitability_gpkg,
              do_count = T)

#####################################
#####################################

# load data
## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_rm_constraints_{date}"))

## submodel datasets
### industry
#### AIS
hex_ais <- sf::st_read(dsn = industry_gpkg,
                       layer = sf::st_layers(industry_gpkg)[[1]][grep(pattern = stringr::str_glue("ais_{date}"),
                                                                         sf::st_layers(dsn = industry_gpkg,
                                                                                       do_count = T)[[1]])]) %>%
  # remove geometry
  sf::st_drop_geometry()

### fisheries
### VMS (all gear, 2015 - 2016)
hex_vms_all <- sf::st_read(dsn = fisheries_gpkg, layer = stringr::str_glue("{region_name}_hex_vms_all_{date}")) %>%
  sf::st_drop_geometry()

### VMS (speeds under 4 / 5 knots, 2015 - 2016)
hex_vms_4_5kn <- sf::st_read(dsn = fisheries_gpkg, layer = stringr::str_glue("{region_name}_hex_vms_4_5_knot_{date}")) %>%
  sf::st_drop_geometry()

### VTR (all gear types)
hex_vtr <- sf::st_read(dsn = fisheries_gpkg, layer = stringr::str_glue("{region_name}_hex_vtr_all_gear_{date}")) %>%
  sf::st_drop_geometry()

### large pelagic survey
hex_lps <- sf::st_read(dsn = fisheries_gpkg, layer = stringr::str_glue("{region_name}_hex_large_pelagic_survey_{date}")) %>%
  sf::st_drop_geometry()

#####################################
#####################################

suitability_model <- hex_grid %>%
  # join the AIS by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = hex_ais,
                   by = "index") %>%
  # join the VMS (all fishing) by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = hex_vms_all,
                   by = "index") %>%
  # join the VMS (slow fishing) by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = hex_vms_4_5kn,
                   by = "index") %>%
  # join the VTR (all gear) by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = hex_vtr,
                   by = "index") %>%
  # join the large pelagic survey by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = hex_lps,
                   by = "index") %>%

  # add value of 1 for datasets when hex cell has value of NA
  ## for hex cells not impacted by a particular dataset, that cell gets a value of 1
  ### this indicates  suitability with wind energy development
  dplyr::mutate(across(2:6, ~replace(x = .,
                                     list = is.na(.),
                                     # replacement values
                                     values = 1)))

test <- suitability_model %>%
  sf::st_drop_geometry()

has_na <- length(rownames(test)[!complete.cases(test)])

#####################################

model_areas <- suitability_model %>%
  # calculate the geometric mean
  ## geometric mean = nth root of the product of the variable values
  dplyr::mutate(model_geom_mean = (ais_max ^ gm_wt) * (vms_all_max ^ gm_wt) * (vms_kt_max ^ gm_wt) * (vtr_max ^ gm_wt) * (lps_max ^ gm_wt)) %>%
  
  # select desired fields
  dplyr::select(index,
                # industry, transportation, and navigation
                ais_max,
                # fisheries
                vms_all_max, vms_kt_max, vtr_max, lps_max,
                # model geometric value
                model_geom_mean)

model_areas <- suitability_model %>%
  # calculate the geometric mean
  ## geometric mean = nth root of the product of the variable values
  dplyr::mutate(model_geom_mean = (ais_max ^ gm_wt) * (vms_all_max ^ gm_wt) * (vtr_max ^ gm_wt) * (lps_max ^ gm_wt)) %>%
  
  # select desired fields
  dplyr::select(index,
                # industry, transportation, and navigation
                ais_max,
                # fisheries
                vms_all_max, vtr_max, lps_max,
                # model geometric value
                model_geom_mean)

dim(model_areas)[1] - dim(model_areas[!is.na(model_areas$constraints), ])[1]
dim(model_areas)[1]

test <- model_areas %>%
  sf::st_drop_geometry()

has_na <- rownames(test)[!complete.cases(test)]

#####################################

# export data
## overall suitability
sf::st_write(obj = model_areas, dsn = suitability_gpkg, layer = stringr::str_glue("{region_name}_suitability_itn_fish_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
