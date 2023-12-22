############################
### 1. Define Study Area ###
############################

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
aoi_dir <- "data/a_raw_data/AOI_polygon_shp"
study_dir <- "data/a_raw_data/studyRegion_polygon"
westport_gpkg <- "data/a_raw_data/Westport_FinalGeoPackage.gpkg"

### output directories
#### Intermediate directories
study_area_gpkg <- "data/b_intermediate_data/westport_study_area.gpkg"

sf::st_layers(dsn = westport_gpkg,
              do_count = T)

#####################################
#####################################

# set parameters
## designate region name
region <- "westport"

## coordinate reference system
### EPSG:26918 is NAD83 / UTM 18N (https://epsg.io/26918)
crs <- "EPSG:26918"

#####################################
#####################################

# load data
## area of interest
aoi_poly <- sf::st_read(dsn = file.path(paste(aoi_dir, "AOI_polygon.shp", sep = "/"))) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs)

## study region
study_region <- sf::st_read(dsn = file.path(paste(study_dir, "studyRegion_constraints_polygon.shp", sep = "/"))) %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs)

#####################################

## original hex grid
westport_grid <- sf::st_read(dsn = westport_gpkg, layer = "studyArea_hexGrids_constrained") %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs) %>%
  # create and index location
  dplyr::mutate(index = row_number()) %>%
  dplyr::relocate(index,
                  .before = GRID_ID)

#####################################
#####################################

# Hexagon area = ((3 * sqrt(3))/2) * side length ^ 2 (https://pro.arcgis.com/en/pro-app/latest/tool-reference/data-management/generatetesellation.htm)
# 1 acre equals approximately 4064.86 square meters
# 10 acres = 40468.6 square meters
# 40468.6 = ((3 * sqrt(3))/2) * side length ^ 2
# 40468.6 * 2 = 3 * sqrt(3) * side length ^ 2 --> 80937.2
# 80937.2 / 3 = sqrt(3) * side length ^ 2 --> 26979.07
# 26979.07 ^ 2 = 3 * side length ^ 4 --> 727870218
# 727870218 / 3 = side length ^ 4 --> 242623406
# 242623406 ^ (1/4) = side length --> 124.8053

# Create 10-acre grid around call areas
study_region_grid <- sf::st_make_grid(x = study_region,
                                   ## see documentation on what cellsize means when relating to hexagons: https://github.com/r-spatial/sf/issues/1505
                                   ## cellsize is the distance between two vertices (short diagonal --> d = square root of 3 * side length)
                                   ### So in this case, square-root of 3 * 124.8053 = 1.73205080757 * 124.8053 = 216.1691
                                   cellsize = 216.1691,
                                   # make hexagon (TRUE will generate squares)
                                   square = FALSE,
                                   # make hexagons orientation with a flat topped (FALSE = pointy top)
                                   flat_topped = TRUE) %>%
  # convert back as sf
  sf::st_as_sf() %>%
  # change to correct coordinate reference system (EPSG:26918 -- NAD83 / UTM 18N)
  sf::st_transform(x = ., crs = crs)

# subset by location: hexagonal grids that intersect with study area
study_region_hex <- study_region_grid[study_region, ] %>%
  # add field "index" that will be populated with the row_number
  dplyr::mutate(index = row_number())

#####################################
#####################################

# export data
## original grid
sf::st_write(obj = westport_grid, dsn = study_area_gpkg, layer = paste(region, "original_grid", sep = "_"), append = F)

## study area
### area of interest
sf::st_write(obj = aoi_poly, dsn = study_area_gpkg, layer = paste(region, "aoi_polygon", sep = "_"), append = F)

### study region
sf::st_write(obj = study_region, dsn = study_area_gpkg, layer = paste(region, "study_region", sep = "_"), append = F)
sf::st_write(obj = study_region_grid, dsn = study_area_gpkg, layer = paste(region, "study_region_grid", sep = "_"), append = F)
sf::st_write(obj = study_region_hex, dsn = study_area_gpkg, layer = paste(region, "study_region_hex", sep = "_"), append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
