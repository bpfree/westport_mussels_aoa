# Westport Areas of Aquaculture -- mussels
## Siting analysis for the Westport, Massachusetts aquaculture area

**Points of contact**  
* **Aquaculture leader:** [Chris Schillaci](mailto:christopher.schillaci@noaa.gov)  
* **Project lead:** [Drew Resnick](mailto:drew.resnick@noaa.gov)

### **Repository Structure**

-   **data**
    -   **raw_data:** the raw data integrated in the analysis (**Note:** original data name and structure were kept except when either name was not descriptive or similar data were put in same directory to simplify input directories)
    -   **intermediate_data:** disaggregated processed data
    -   **submodel_data:** processed data for analyzing in the wind siting submodel
    -   **suitability_data:** final suitability data for offshore wind area region
    -   **rank_data:**
    -   **sensitivity_data:**
    -   **uncertainty_data:**
-   **code:** scripts for cleaning, processing, and analyzing data
-   **figures:** figures generated to visualize analysis
-   **methodology:** detailed [methods]() for the data and analysis

***Note for PC users:*** The code was written on a Mac so to run the scripts replace "/" in the pathnames for directories with two "\\".

Please contact Brian Free ([brian.free@noaa.gov](mailto:brian.free@noaa.gov)) with any questions regarding the code.

### **Study region**
The aquaculture analysis focused on finding suitable sites in federal waters off the coast from Westport, Massachusetts. The site needed to be within 20-miles of Westport and have depths between -20 and -40 meters. A hexagonal grid with 10-acre cells covered all federal waters within 20 miles of Westport and had depths between -20 and -40 meters.

### **Data sources**
#### *Generic Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Temperature | NOAA | [EMU water quality](https://marinecadastre.gov/downloads/data/mc/EMUWaterQuality.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/66137) |  |
| Sediment | NOAA  | [Sediment texture](https://marinecadastre.gov/downloads/data/mc/SedimentTexture.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/55364) | [MarineCadastre](https://hub.marinecadastre.gov/datasets/noaa::sediment-texture) contains more information |
| Sediment | [Northeast Ocean Data](https://www.northeastoceandata.org/)  | [Sediment size](https://easterndivision.s3.amazonaws.com/Marine/MooreGrant/Sediment.zip) | [Metadata](https://easterndivision.s3.amazonaws.com/Marine/MooreGrant/SoftSediment.pdf) | TNC provided the data |

#### *Constraints Data*
##### *Regional*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Bathymetry | NOAA | [CUDEM, 1/9-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/rima/ncei19_n41x50_w071x00_2018v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199919.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://coast.noaa.gov/dataviewer/#/lidar/search/where:ID=8580), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the [FTP server](ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) even though browsers do not support it any more and the correct directory is MA_NH_ME |
| Bathymetry | NOAA | [CUDEM, 1/9-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/rima/ncei19_n41x50_w071x25_2018v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199919.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://coast.noaa.gov/dataviewer/#/lidar/search/where:ID=8580), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the [FTP server](ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) even though browsers do not support it any more and the correct directory is MA_NH_ME |
| Bathymetry | NOAA | [CUDEM, 1/9-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/rima/ncei19_n41x50_w071x50_2018v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199919.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://coast.noaa.gov/dataviewer/#/lidar/search/where:ID=8580), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the [FTP server](ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) even though browsers do not support it any more and the correct directory is MA_NH_ME |
| Bathymetry | NOAA | [CUDEM, 1/3-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/MA_NH_ME/ncei13_n41x25_w071x00_2021v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199913.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the [FTP server](ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_third_Topobathy_2014_8580/) even though browsers do not support it any more and the correct directory is rima |
| Bathymetry | NOAA | [CUDEM, 1/3-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/MA_NH_ME/ncei13_n41x25_w071x25_2021v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199913.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the [FTP server](ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_third_Topobathy_2014_8580/) even though browsers do not support it any more and the correct directory is rima |
| Bathymetry | NOAA | [CUDEM, 1/3-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/MA_NH_ME/ncei13_n41x25_w071x50_2021v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199913.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the [FTP server](ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_third_Topobathy_2014_8580/) even though browsers do not support it any more and the correct directory is rima |
| Administrative boundary | NOAA | [Federal waters](https://marinecadastre.gov/downloads/data/mc/CoastalZoneManagementAct.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/53132) |  |
| Administrative boundary | [Masschusetts](https://www.mass.gov/info-details/massgis-data-layers)  | [Town survey](https://s3.us-east-1.amazonaws.com/download.massgis.digital.mass.gov/gdbs/townssurvey_gdb.zip) | [Metadata](https://www.mass.gov/info-details/massgis-data-municipalities) | [MASSGIS](https://www.mass.gov/orgs/massgis-bureau-of-geographic-information) |

##### *Model*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Unexploded ordnance | NOAA | [Unexploded ordnance locations](https://marinecadastre.gov/downloads/data/mc/UnexplodedOrdnance.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/66208) | As of 17 January 2024, MarineCadastre will not return any results for unexploded ordnance data; these data came from links located for previous analyses |
| Unexploded ordnance | NOAA | [Munitions and explosives of concern](https://marinecadastre.gov/downloads/data/mc/MunitionsExplosivesConcern.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/69013) | MECs are replacing the UXOs as the default dataset |
| Danger zones | NOAA | [Danger zones and restricted areas](https://marinecadastre.gov/downloads/data/mc/DangerZoneRestrictedArea.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/48876) | [MarineCadastre](https://hub.marinecadastre.gov/datasets/noaa::danger-zones-and-restricted-areas) contains more information |
| Environmental sensors | [Northeast Ocean Data Portal](https://www.northeastoceandata.org/) | [Environmental sensors and buoys](https://www.northeastoceandata.org/files/metadata/Themes/PhysicalOceanography.zip) | [Metadata](https://www.northeastoceandata.org/files/metadata/Themes/PhysicalOceanography/NERACOOSBuoys.htm) |  |
| Wastewater facilities | NOAA | [Wastewater outfall facilities](https://marinecadastre.gov/downloads/data/mc/WastewaterOutfall.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/66706) | [MarineCadastre](https://hub.marinecadastre.gov/datasets/b0c5d61277f440e3b6ca001f7fbd5416_0) contains more information, also please note that the download link is the same for the [wastewater outfall pipes data](https://hub.marinecadastre.gov/datasets/noaa::wastewater-outfall-pipes) and the [wastewater outfalls data](https://marinecadastre.gov/downloads/data/mc/WastewaterOutfall.zip) |
| Ocean disposal | NOAA | [Ocean disposal sites](https://marinecadastre.gov/downloads/data/mc/OceanDisposalSite.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/54193) | [MarineCadastre](https://hub.marinecadastre.gov/datasets/noaa::ocean-disposal-sites) contains more information |
| Navigation | NOAA | [Aids to Navigation](https://marinecadastre.gov/downloads/data/mc/AtoN.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/56120) | [MarineCadastre](https://hub.marinecadastre.gov/datasets/noaa::aids-to-navigation-2) contains more information |
| Obstructions | NOAA | [Wrecks and obstructions](https://marinecadastre.gov/downloads/data/mc/WreckObstruction.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/70439) | [MarineCadastre](https://hub.marinecadastre.gov/datasets/noaa::wrecks-and-obstructions) contains more information |
| Shipping | NOAA | [Shipping lanes (federal)](http://encdirect.noaa.gov/theme_layers/data/shipping_lanes/shippinglanes.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/39986) | Note these data are for shipping lanes in federal waters |
| Wind | BOEM | [Offshore Wind - export cable corridors (proposed)](https://hub.marinecadastre.gov/datasets/BOEM::offshore-wind-export-cable-corridors-proposed) | [Metadata](https://www.arcgis.com/sharing/rest/content/items/0e57fcbb8aaf49c5b8d0944a4ffeef08/info/metadata/metadata.xml?format=default&output=html) | [REST Service](https://services7.arcgis.com/G5Ma95RzqJRPKsWL/arcgis/rest/services/Offshore_Wind-_Proposed_Export_Cable_Corridors/FeatureServer/0) |
| Wind | BOEM | [Offshore wind call areas](https://www.boem.gov/BOEM-Renewable-Energy-Geodatabase.zip) | [Metadata](https://www.arcgis.com/sharing/rest/content/items/709831444a234968966667d84bcc0357/info/metadata/metadata.xml?format=default&output=html) | [BOEM source (geodatabase)](https://www.boem.gov/renewable-energy/mapping-and-data/renewable-energy-gis-data), online download [link](https://www.boem.gov/renewable-energy/boem-renewable-energy-geodatabase)

#### *Costs Data*
##### *National Security Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Unexploded ordnance | NOAA | [Unexploded ordnance areas](https://marinecadastre.gov/downloads/data/mc/UnexplodedOrdnanceArea.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/66206) | As of 17 January 2024, MarineCadastre will not return any results for unexploded ordnance data; these data came from links located for previous analyses |
| Airspace | NOAA | [Special use airspace](https://marinecadastre.gov/downloads/data/mc/MilitaryCollection.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/48898) | [MarineCadastre](https://hub.marinecadastre.gov/datasets/noaa::military-special-use-airspace) contains more information; an older [link](https://marinecadastre.gov/downloads/data/mc/MilitarySpecialUseAirspace.zip) for these data should not get used for those data have become deprecated (according to [Daniel Martin](mailtio:daniel.martin@noaa.gov) as of 31 January 2024) |
| Military | [Data.gov](https://data.gov/) | [Military operating areas](https://marinecadastre.gov/downloads/data/mc/MilitaryCollection.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/55364) | MarineCadastre contains an alternative [download link](https://marinecadastre.gov/downloads/data/mc/MilitaryOperatingAreaBoundary.zip), yet these data are deprecated as of 9 February 2024 and contain different objects, though both datasets have the same data for the study region |

##### *Industry, Transportation, and Navigation Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| AIS | [Northeast Ocean Data](https://www.northeastoceandata.org/) | [AIS vessel tracks (counts)](https://services.northeastoceandata.org/downloads/AIS/AIS2022_Annual.zip) | [Metadata](https://www.northeastoceandata.org/files/metadata/Themes/AIS/AllAISVesselTransitCounts2022.pdf) | For data downloads at Northeast Ocean Data, use this [link](https://www.northeastoceandata.org/data-download/)

##### *Fisheries Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| VMS | --------- | VMS (all fishing) | [Metadata](https://www.northeastoceandata.org/files/metadata/Themes/CommercialFishing/VMSCommercialFishingDensity.pdf) | Fisheries effort for 2015 and 2016, [additional documentation](https://www.northeastoceandata.org/files/metadata/Themes/CommercialFishing/VMSCommercialFishingDensity_2022.pdf) |
| VMS | --------- | VMS (slow fishing) | [Metadata](https://www.northeastoceandata.org/files/metadata/Themes/CommercialFishing/VMSCommercialFishingDensity.pdf) | Fishing vessels under speeds 4 or 5 knots (depends on the fishery) and for 2015 and 2016, [additional documentation](https://neoceanplanning.org/wp-content/uploads/2021/09/Portal_FisheriesData_FinalReport_2021.pdf) |
| VTR | --------- | VTR (all gear) |---------- | ---------------|
| VTR | --------- | VTR (charter / party) | ----------|--------------- |
| Survey | --------- | Large pelagic survey (2012 - 2021) |---------- | ---------------|
| Cod |--------- | [Cod spawning protection areas](https://media.fisheries.noaa.gov/2020-04/gom-spawning-groundfish-closures-20180409-noaa-garfo.zip) | [Metadata](https://media.fisheries.noaa.gov/dam-migration/gom-spawning-groundfish-closures-metadata-noaa-fisheries_.pdf) |[PDF maps](https://media.fisheries.noaa.gov/dam-migration/gom-spawning-groundfish-closures-map-noaa-fisheries_.pdf) |
| Cod |--------- | Known cod spawning areas | ----------| Not in study region |

##### *Natural and Cultural Resources Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Protected resources |-------------- | Combined protected resources |-------------- | --------------|

### **Data commentary**
Datasets explored but not included in analyses due to not geographically located in study region:

  - [Wastewater outfall structures](https://www.fisheries.noaa.gov/inport/item/66706)
  - [Ocean disposal](https://www.fisheries.noaa.gov/inport/item/56120)
  - [Special use airspace](https://www.fisheries.noaa.gov/inport/item/48898)
  - [VTR (charter / party)]()
  - [Cod spawning protection areas](https://media.fisheries.noaa.gov/dam-migration/gom-spawning-groundfish-closures-metadata-noaa-fisheries_.pdf)
  - [Known cod spawning areas]()

### **Methodologies**
#### *Software*
All data cleaning and analyses were performed using the R programming software (version 4.3.2, R Core Team 2023). Especially important R packages used include: dplyr(1.1.4), rmapshaper(0.5.0), sf(1.0-15), terra(1.7-65).

While most data used in the model received a single value, some ranged between 0 and 1. This caused at times a hex cells across the call areas to have more than a single value due to data not sharing the exact same shape and size as the call are hex cells. When this occurred, the analysis chose the maximum value occurring in the hex cell.

#### *Constraints*
Any hex indexes that got affected by constraints got removed from the siting analysis.

#### *Costs*
| **Submodel** | **Layer** | **Buffer distance (m)** | **Score** | **Notes** |
|---------------|---------------|---------------|---------------|---------------|
| National Securtity | Military operating areas | -------------- | 1 | Removed from second model iteration |
| Industry | AIS | -------------- | Z-shaped membership function | --------------- |
| Fisheries | VMS (all gear) | -------------- | Z-shaped membership function | --------------- |
| Fisheries | VMS (slow fishing) | -------------- | Z-shaped membership function | slow fishing is considered between 4 - 5 knots |
| Fisheries | VTR (all gear) | -------------- | Z-shaped membership function | --------------- |
| Fisheries | Large pelagic survey | 16093.4 | Z-shaped membership function | --------------- |
| Natural and Cultural | Protected resources | -------------- | Z-shaped membership function | Removed from second model iteration |

#### *z-shaped membership function*
Data layers with continuous data had their values rescaled between 0 and 1 using an adapted [z-shaped memebership function](https://www.mathworks.com/help/fuzzy/zmf.html#d126e54766) adapted from Matlab's methods. The z-shaped membership function rescaled values so that minimum values receive a score of 1 and as the values increase to the maximum, the rescaled score approaches 0. In the normal Matlab function, the maximum value would get the rescaled value of 0; however, scores of 0 got classified as constraints -- areas not permitted for aquaculture. To avoid rescaled continuous data getting scores of 0, the maximum value received an extra one-thousandth of the maximum value (*i.e.*, maximum value * 1/1000).

The z-shaped membership function required additional adaptation for the vessel monitoring system data for these data had negative values. These data had fishing densities standardized and the [authors noted](https://www.northeastoceandata.org/files/metadata/Themes/CommercialFishing/VMSCommercialFishingDensity.pdf) that the results were best to understand qualitatively through its five classes: very high, high, medium-high, medium-low, and low. A z-shaped membership function assumes that all values are positive. The absolute value of the minimum standardized fishing densities, which can then get added to every value across the dataset to have only positive values for running the normal z-shaped membership function on these shifted values.

#### *Data*
For any data not already in the coordinate reference system, they were transformed to the coordinate reference system of EPSG:26918 is [NAD83 / UTM 18N](https://epsg.io/26918) to ensure layering and analysis. Many datasets covered areas beyond the study region; when this occurred, the analysis only considered data within the study region. For constraints data, a value field was added and given a value of 0. When a layer had multiple datasets, those datasets were combined; then the combined datasets were 

Data examined but not existing within original region

1. WWTF outfall structures
2. Ocean disposal sites
3. Special use airspace
4. Cod spawning protection areas
5. VTR (charter / party)
6. Known cod spawning areas

Data examined but not existing within -20m and -40m of federal waters that are within 20 miles of Westport

1. Wastewater outfall structures
2. Ocean disposal
3. Special use airspace
4. VTR (charter / party)
5. Cod spawning protection areas
6. Known cod spawning areas

#### *Submodels*
* National Security: currently integrates one datasets (military operating areas) for the other two datasets aimed to get integrated in the submodel were removed due to separate reasons;
no special use airspace overlapped with the Westport study region and unexploded ordnance data got deprecated and replaced with the munitions and explosives of concern

* Industry: only AIS dataset got ingested within this submodel

* Fisheries: four datasets integrated in model (VMS [all fishing (2015-2016)], VMS [all fishing under 4 / 5 knots(2015-2016)], VTR [all gear types], large pelagic survey [2012 - 2021])

* Natural and cultural resources: protected resources got removed for the final analysis

### **Model Runs**
*8 October 2024*
- Proposed export offshore wind cable corridors act as constraint
- Munitions and explosives of concern replace unexploded ordnance locations and areas (act as constraint)
- Remove combined protected resources from analysis
- Remove military operating areas for all cells would get a value of 1 (for presence or lack of presence)
- Any hex with constraint gets removed from final analysis

### **Issues**
1. Munitions and explosives of concern superseded the unexploded ordnance data, so those data replaced the previous dataset in the analysis. Given that previously the location data had a
setback distance applied to it so that the 1-dimensional points had geographic space, that setback distance was no longer required for the munitions and explosives of concern.

2. Noticed on 6 February 2025, VMS data for all fisheries got the mean taken. At the time of the analysis, little guidance was provided on if the mean or the sum should get taken.
