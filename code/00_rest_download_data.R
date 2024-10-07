#################################################
### 02. Download Data -- REST server download ###
#################################################

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

data_dir <- "data/a_raw_data"

#####################################
#####################################

rest_services_function <- function(url_list, base_url, data_dir){
  # define base URL (the service path)
  base_url <- base_url
  
  # define the unique dataset URL ending
  full_url <- url_list
  
  # combine the base with the dataset URL to create the entire data URL
  data_url <- file.path(base_url, full_url)
  
  # pull the spatial layer from the REST server
  data <- arcpullr::get_spatial_layer(data_url)
  
  # get the unique data name (when applicable)
  dir_name <- stringr::str_split(url_list, pattern = "/")[[1]][1]
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  # set the new pathname to export the data
  new_dir <- file.path(data_dir, dir_name)
  
  # export the dataset
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}

#####################################

# Set directories
## output directory
data_dir <- "data/a_raw_data"

#####################################
#####################################

rest_services_function <- function(url_list, base_url, data_dir){
  # define base URL (the service path)
  base_url <- base_url
  
  # define the unique dataset URL ending
  full_url <- url_list
  
  # combine the base with the dataset URL to create the entire data URL
  data_url <- file.path(base_url, full_url)
  
  # pull the spatial layer from the REST server
  data <- arcpullr::get_spatial_layer(data_url)
  
  # get the unique data name (when applicable)
  dir_name <- stringr::str_split(url_list, pattern = "/")[[1]][1]
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  # set the new pathname to export the data
  new_dir <- file.path(data_dir, dir_name)
  
  # export the dataset
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}

#####################################
#####################################

# Offshore Wind - Export Cable Corridors (Proposed)
## Marine Cadastre: https://hub.marinecadastre.gov/datasets/BOEM::offshore-wind-export-cable-corridors-proposed
## metadata: https://www.arcgis.com/sharing/rest/content/items/0e57fcbb8aaf49c5b8d0944a4ffeef08/info/metadata/metadata.xml?format=default&output=html
## REST server: https://services7.arcgis.com/G5Ma95RzqJRPKsWL/arcgis/rest/services/Offshore_Wind-_Proposed_Export_Cable_Corridors/FeatureServer/0

# URL list
url_list <- "Offshore_Wind-_Proposed_Export_Cable_Corridors/FeatureServer/0"

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://services7.arcgis.com/G5Ma95RzqJRPKsWL/arcgis/rest/services/", data_dir = data_dir)

parallel::stopCluster(cl = cl)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate