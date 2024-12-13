#############################
### 32. Suitability model ###
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

## layer names
layer_name <- "suitability"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

## geometric mean weight
### four submodels are: national security, industry / transportation / navigation, fisheries, and natural / cultural resources
gm_wt <- 1/4

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

#### suitability geopackage
suitability_gpkg <- stringr::str_glue("data/d_suitability_data/{layer_name}.gpkg")

## Output directories
### suitability directory
suitability_dir <- "data/d_suitability_data"
dir.create(file.path(suitability_dir, "overall_suitability"))

overall_suitability_dir <- "data/d_suitability_data/overall_suitability"
overall_suitability_gpkg <- stringr::str_glue("data/d_suitability_data/overall_suitability/{region_name}_overall_suitability.gpkg")

#####################################

# inspect layers within geopackage
sf::st_layers(dsn = region_gpkg,
              do_count = T)

sf::st_layers(dsn = suitability_gpkg,
              do_count = T)

#####################################
#####################################

# load data
## hex grid
hex_grid <- sf::st_read(dsn = region_gpkg, layer = stringr::str_glue("{region_name}_hex_rm_constraints_{date}"))

### national security
national_security <- sf::st_read(dsn = suitability_gpkg,
                                 layer = sf::st_layers(suitability_gpkg)[[1]][grep(pattern = stringr::str_glue("security_{layer_name}_{date}"),
                                                                                   sf::st_layers(dsn = suitability_gpkg,
                                                                                                 do_count = T)[[1]])]) %>%
  # remove geometry
  sf::st_drop_geometry()

### industry, transportation, and navigation
industry <- sf::st_read(dsn = suitability_gpkg,
                        layer = sf::st_layers(suitability_gpkg)[[1]][grep(pattern = stringr::str_glue("industry_{layer_name}_{date}"),
                                                                          sf::st_layers(dsn = suitability_gpkg,
                                                                                        do_count = T)[[1]])]) %>%
  # remove geometry
  sf::st_drop_geometry()

### fisheries
fisheries <- sf::st_read(dsn = suitability_gpkg,
                         layer = sf::st_layers(suitability_gpkg)[[1]][grep(pattern = stringr::str_glue("fisheries_{layer_name}_{date}"),
                                                                           sf::st_layers(dsn = suitability_gpkg,
                                                                                         do_count = T)[[1]])]) %>%
  # remove geometry
  sf::st_drop_geometry()

### natural and cultural resources
natural_cultural <- sf::st_read(dsn = suitability_gpkg,
                                 layer = sf::st_layers(suitability_gpkg)[[1]][grep(pattern = stringr::str_glue("cultural_{layer_name}_{date}"),
                                                                                   sf::st_layers(dsn = suitability_gpkg,
                                                                                                 do_count = T)[[1]])]) %>%
  # remove geometry
  sf::st_drop_geometry()

#####################################
#####################################

suitability_model <- hex_grid %>%
  # join the national security areas by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = national_security,
                   by = "index") %>%
  # join the industry, transportation, and navigation areas by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = industry,
                   by = "index") %>%
  # join the fisheries areas by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = fisheries,
                   by = "index") %>%
  # join the natural and cultural resources areas by index field to the full Westport hex grid
  dplyr::left_join(x = .,
                   y = natural_cultural,
                   by = "index")

#####################################

model_areas <- suitability_model %>%
  # calculate the geometric mean
  ## geometric mean = nth root of the product of the variable values
  dplyr::mutate(model_geom_mean = (ns_geom_mean ^ gm_wt) * (itn_geom_mean ^ gm_wt) * (fish_geom_mean ^ gm_wt) * (nc_geom_mean ^ gm_wt)) %>%
  
  # select desired fields
  dplyr::select(index,
                # national security
                military_operating_value,
                # industry, transportation, and navigation
                ais_max,
                # fisheries
                vms_all_max, vms_kt_max, vtr_max, lps_max,
                # natural and cultural resources
                cpr_max,
                # submodel geometric values
                ns_geom_mean, itn_geom_mean, fish_geom_mean, nc_geom_mean,
                # model geometric value
                model_geom_mean)

dim(model_areas)[1] - dim(model_areas[!is.na(model_areas$constraints), ])[1]
dim(model_areas)[1]

#####################################

# export data
## overall suitability
sf::st_write(obj = model_areas, dsn = suitability_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

## submodels
saveRDS(object = national_security, file = file.path(overall_suitability_dir, stringr::str_glue("{region_name}_hex_{layer_name}_national_security_{date}.rds")))
saveRDS(object = industry, file = file.path(overall_suitability_dir, stringr::str_glue("{region_name}_hex_{layer_name}_industry_{date}.rds")))
saveRDS(object = fisheries, file = file.path(overall_suitability_dir, stringr::str_glue("{region_name}_hex_{layer_name}_fisheries_{date}.rds")))
saveRDS(object = natural_cultural, file = file.path(overall_suitability_dir, stringr::str_glue("{region_name}_hex_{layer_name}_natural_cultural_{date}.rds")))

## model
sf::st_write(obj = model_areas, dsn = overall_suitability_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
