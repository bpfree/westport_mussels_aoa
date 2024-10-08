########################################
### 26. Combined protected resources ###
########################################

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
layer_name <- "combined_protected_resources"

## submodel
submodel <- "natural_cultural"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
### input directories
#### combined protected resources
data_dir <- "data/a_raw_data/combined_protected_resources"

#### study area grid
region_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_study_area.gpkg")

### output directories
#### natural and cultural resources
submodel_gpkg <- stringr::str_glue("data/c_submodel_data/{submodel}.gpkg")

#### intermediate directories
output_gpkg <- stringr::str_glue("data/b_intermediate_data/{region_name}_{layer_name}.gpkg")

#####################################

# inspect layers within geopackage
sf::st_layers(dsn = region_gpkg,
              do_count = T)

#####################################
#####################################

# function
## z-membership function
### Adapted from https://www.mathworks.com/help/fuzzy/zmf.html
zmf_function <- function(combined_protected_resources){
  
  # calculate minimum value
  min <- min(combined_protected_resources$cpr_value)
  
  # calculate maximum value
  max <- max(combined_protected_resources$cpr_value)
  
  # calculate z-score minimum value
  ## this ensures that no value gets a value of 0
  z_max <- max + (max * 1 / 1000)
  
  # create a field and populate with the value determined by the z-shape membership scalar
  combined_protected_resources <- combined_protected_resources %>%
    # calculate the z-shape membership value (more desired values get a score of 1 and less desired values will decrease till 0.01)
    ## ***Note: in other words, habitats with higher richness values will be closer to 0
    dplyr::mutate(cpr_z_value = ifelse(cpr_value == min, 1, # if value is equal to minimum, score as 1
                                   # if value is larger than minimum but lower than mid-value, calculate based on scalar equation
                                   ifelse(cpr_value > min & cpr_value < (min + z_max) / 2, 1 - 2 * ((cpr_value - min) / (z_max - min)) ** 2,
                                          # if value is lower than z_maximum but larger than than mid-value, calculate based on scalar equation
                                          ifelse(cpr_value >= (min + z_max) / 2 & cpr_value < z_max, 2 * ((cpr_value - z_max) / (z_max - min)) ** 2,
                                                 # if value is equal to maximum, value is equal to 0.01 [all other values should get an NA]
                                                 ifelse(cpr_value == z_max, 0.01, NA)))))
  
  # return the layer
  return(combined_protected_resources)
}

#####################################
#####################################

# load data
## combined protected resources data
data <- sf::st_read(dsn = file.path(paste(data_dir, "final_PRD_CEATL_WP.shp", sep = "/"))) %>%
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
  # obtain only combined protected resources in the study area
  rmapshaper::ms_clip(target = .,
                      clip = region) %>%
  # create field called "layer" and fill with "combined protected resources" for summary
  dplyr::mutate(layer = "combined protected resources")

#####################################
#####################################

# combined protected resources hex grids
region_data_hex <- hex_grid[region_data, ] %>%
  # spatially join combined protected resources values to Westport hex cells
  sf::st_join(x = .,
              y = region_data,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(index, layer, GEO_MEAN) %>%
  # rename "GEO_MEAN" field
  dplyr::rename(cpr_value = GEO_MEAN) %>%
  # calculate z-values
  zmf_function() %>%
  # relocate the z-value field
  dplyr::relocate(cpr_z_value, .after = cpr_value) %>%
  # group by the index values as there are duplicates
  dplyr::group_by(index) %>%
  # summarise the fisheries score values
  ## take the maximum value of the combined protected resource score for any that overlap
  ## ***Note: this will provide the most conservation given that high values are less desirable
  dplyr::summarise(cpr_max = max(cpr_z_value))

#####################################
#####################################

# export data
## constraints geopackage
sf::st_write(obj = region_data_hex, dsn = submodel_gpkg, layer = stringr::str_glue("{region_name}_hex_{layer_name}_{date}"), append = F)

## combined protected resources geopackage
sf::st_write(obj = data, dsn = output_gpkg, layer = stringr::str_glue("{layer_name}_{date}"), append = F)
sf::st_write(obj = region_data, dsn = output_gpkg, layer = stringr::str_glue("{region_name}_{layer_name}_{date}"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
