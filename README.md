# Westport Areas of Aquaculture -- mussels
## Siting analysis for the Westport, Massachusetts aquaculture area

**Points of contact**
* **Aquaculture leader:** [Chris Schillaci](mailto:christopher.schillaci@noaa.gov)
* **Project lead:** [Drew Resnick](mailto:drew.resnick@noaa.gov)

#### **Repository Structure**

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

#### **Data sources**
##### *Generic Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Administrative boundary | NOAA | [Federal waters](https://marinecadastre.gov/downloads/data/mc/CoastalZoneManagementAct.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/53132) |  |
| Temperature | NOAA | [EMU water quality](https://marinecadastre.gov/downloads/data/mc/EMUWaterQuality.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/66137) |  |
| Administrative boundary | [Masschusetts]()  | [Town survey](https://s3.us-east-1.amazonaws.com/download.massgis.digital.mass.gov/gdbs/townssurvey_gdb.zip) | [Metadata](https://www.mass.gov/info-details/massgis-data-municipalities) | Massachusetts GIS [data page](https://www.mass.gov/info-details/massgis-data-layers) |

##### *Constraints Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Bathymetry | NOAA | [CUDEM, 1/9-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/rima/ncei19_n41x50_w071x00_2018v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199919.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://coast.noaa.gov/dataviewer/#/lidar/search/where:ID=8580), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the FTP server even though browsers do not support it any more: (ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) and the correct directory is MA_NH_ME |
| Bathymetry | NOAA | [CUDEM, 1/9-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/rima/ncei19_n41x50_w071x25_2018v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199919.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://coast.noaa.gov/dataviewer/#/lidar/search/where:ID=8580), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the FTP server even though browsers do not support it any more: (ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) and the correct directory is MA_NH_ME |
| Bathymetry | NOAA | [CUDEM, 1/-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/rima/ncei19_n41x50_w071x50_2018v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199919.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://coast.noaa.gov/dataviewer/#/lidar/search/where:ID=8580), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the FTP server even though browsers do not support it any more: (ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_ninth_Topobathy_2014_8483/) and the correct directory is MA_NH_ME |
| Bathymetry | NOAA | [CUDEM, 1/3-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/MA_NH_ME/ncei13_n41x25_w071x00_2021v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199913.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the FTP server even though browsers do not support it any more: (ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_third_Topobathy_2014_8580/) and the correct directory is rima |
| Bathymetry | NOAA | [CUDEM, 1/3-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/MA_NH_ME/ncei13_n41x25_w071x25_2021v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199913.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the FTP server even though browsers do not support it any more: (ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_third_Topobathy_2014_8580/) and the correct directory is rima |
| Bathymetry | NOAA | [CUDEM, 1/3-arc second](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/MA_NH_ME/ncei13_n41x25_w071x50_2021v1.tif) | [Metadata](https://data.noaa.gov/metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM//iso/xml/199913.xml&view=xml2text/xml-to-text-ISO) | Explore data [here](https://www.ncei.noaa.gov/maps/bathymetry/), for a [bulk down](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/), while other options for [individual downloads](https://chs.coast.noaa.gov/htdata/raster2/elevation/NCEI_third_Topobathy_2014_8580/) can provide ways to get DEMs that cover the area of interest while also providing detailed attention to specific areas. ***Note: the data can also get accessed throught the FTP server even though browsers do not support it any more: (ftp://ftp.coast.noaa.gov/pub/DigitalCoast/raster2/elevation/NCEI_third_Topobathy_2014_8580/) and the correct directory is rima |

| Military | Department of Defense | Combined Wind Assessment for the Oregon Offshore, BOEM, OPNAV, May 2022 | [Metadata](https://www.coastalatlas.net/waf/boem/OPNAV_CombinedAssesment_May2022.xml) | [Data Portal](https://offshorewind.westcoastoceans.org/) (Human > Military > Combined Oregon Offshore Wind Assessment, OPNAV, May 2022), [Data source provider](https://gis.lcd.state.or.us/server/rest/services/Projects/OCMP_OceanPlanning_Human/MapServer/21), Alternative [link](https://portal.westcoastoceans.org/geoportal/rest/metadata/item/45b6aa29abe7427a91d8f430eac0ab75/html) for dataset, [InPort](https://www.fisheries.noaa.gov/inport/item/48875)
| Military | United States Coast Guard | [Pacific Coast Port Access Route Study](https://navcen.uscg.gov/sites/default/files/pdf/PARS/PAC_PARS_22/Draft%20PAC-PARS.pdf) | | [Federal Registrar](https://www.federalregister.gov/documents/2022/08/26/2022-18453/port-access-route-study-the-pacific-coast-from-washington-to-california), Analysis completed in Districts 11 and 13

##### *Industry and Operations Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Submarine Cable | NOAA | [NOAA Chartered Submarine Cable](https://marinecadastre.gov/downloads/data/mc/SubmarineCable.zip) | [Metadata](https://www.fisheries.noaa.gov/inport/item/57238)| |


##### *Natural Resources Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Conservation Areas | NOAA | [Essential Fisheries Habitat Conservation Areas](https://www.habitat.noaa.gov/protection/efh/newInv/data/west_coast/westcoast_efha.zip) | | [Text](https://www.ecfr.gov/current/title-50/chapter-VI/part-660/subpart-C/section-660.76), [Essential Fish Habitat Mapper](https://www.habitat.noaa.gov/apps/efhmapper/?data_id=dataSource_13-EFHA_7887%3A102&page=page_4), [Alternative download source](https://www.fisheries.noaa.gov/s3/2021-02/EFH-HAPC-EFHCA-shapefiles-AM19-2006-AM28-2020.zip) |
| Habitat | NOAA | [Leatherback Sea Turtle](https://noaa.maps.arcgis.com/home/item.html?id=f66c1e33f91d480db7d1b1c1336223c3) | [Metadata](https://www.fisheries.noaa.gov/inport/item/65327) | [NMFS ESA Critical Habitat Mapper](https://noaa.maps.arcgis.com/apps/webappviewer/index.html?id=68d8df16b39c48fe9f60640692d0e318), [InPort](https://www.fisheries.noaa.gov/inport/item/65207), [West Coast Specific Download](https://www.webapps.nwfsc.noaa.gov/portal7/home/item.html?id=40d9b14ae87e4023ae07361cf3067007), [West Coast Region Protected Resources App](https://www.webapps.nwfsc.noaa.gov/portal/apps/webappviewer/index.html?id=7514c715b8594944a6e468dd25aaacc9), [Code of Regulations](https://www.ecfr.gov/current/title-50/chapter-II/subchapter-C/part-226/section-226.207) |
| Habitat | NOAA | [Humpback Whale (Central America DPS)](https://noaa.maps.arcgis.com/home/item.html?id=f66c1e33f91d480db7d1b1c1336223c3) | [Metadata](https://www.fisheries.noaa.gov/inport/item/65375) | [NMFS ESA Critical Habitat Mapper](https://noaa.maps.arcgis.com/apps/webappviewer/index.html?id=68d8df16b39c48fe9f60640692d0e318), [InPort](https://www.fisheries.noaa.gov/inport/item/65207), [West Coast Specific Download](https://www.webapps.nwfsc.noaa.gov/portal7/home/item.html?id=40d9b14ae87e4023ae07361cf3067007), [West Coast Region Protected Resources App](https://www.webapps.nwfsc.noaa.gov/portal/apps/webappviewer/index.html?id=7514c715b8594944a6e468dd25aaacc9), [Code of Regulations](https://www.ecfr.gov/current/title-50/chapter-II/subchapter-C/part-226/section-226.227) |
| Habitat | NOAA | [Humpback Whale (Mexico DPS)](https://noaa.maps.arcgis.com/home/item.html?id=f66c1e33f91d480db7d1b1c1336223c3) | [Metadata](https://www.fisheries.noaa.gov/inport/item/65377) | [NMFS ESA Critical Habitat Mapper](https://noaa.maps.arcgis.com/apps/webappviewer/index.html?id=68d8df16b39c48fe9f60640692d0e318), [InPort](https://www.fisheries.noaa.gov/inport/item/65207), [West Coast Specific Download](https://www.webapps.nwfsc.noaa.gov/portal7/home/item.html?id=40d9b14ae87e4023ae07361cf3067007), [West Coast Region Protected Resources App](https://www.webapps.nwfsc.noaa.gov/portal/apps/webappviewer/index.html?id=7514c715b8594944a6e468dd25aaacc9), [Code of Regulations](https://www.ecfr.gov/current/title-50/chapter-II/subchapter-C/part-226/section-226.227) |
| Habitat | NOAA | [Killer Whale (Southern Resident)](https://noaa.maps.arcgis.com/home/item.html?id=f66c1e33f91d480db7d1b1c1336223c3) | [Metadata](https://www.fisheries.noaa.gov/inport/item/65409) | [NMFS ESA Critical Habitat Mapper](https://noaa.maps.arcgis.com/apps/webappviewer/index.html?id=68d8df16b39c48fe9f60640692d0e318), [InPort](https://www.fisheries.noaa.gov/inport/item/65207), [West Coast Specific Download](https://www.webapps.nwfsc.noaa.gov/portal7/home/item.html?id=40d9b14ae87e4023ae07361cf3067007), [West Coast Region Protected Resources App](https://www.webapps.nwfsc.noaa.gov/portal/apps/webappviewer/index.html?id=7514c715b8594944a6e468dd25aaacc9), [Code of Regulations](https://www.ecfr.gov/current/title-50/chapter-II/subchapter-C/part-226/section-226.206) |
| Habitat | NOAA | [U.S. West Coast Cross-Shelf Habitat Suitability Modeling of Deep-Sea Corals and Sponges](https://www.ncei.noaa.gov/archive/archive-management-system/OAS/bin/prd/jquery/download/276883.1.1.tar.gz) | [Metadata](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:0276883;view=iso) | [NCEI](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:0276883), [Link](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:0276883) for habitat suitability data only |
| Habitat | NOAA | [Methane Bubble Streams](https://www.pmel.noaa.gov/eoi/Cascadia/Supplemental-Tables-US-only-revised-dec30-2020.xlsx) | | [Merle et al. (2021)](https://www.frontiersin.org/articles/10.3389/feart.2021.531714/full), data come from the supplemental table and contain points from Reidel et al. (2018) and Johnson et al. (2015) |
| Habitat | NOAA | [Methane Bubble Streams](https://www.pmel.noaa.gov/eoi/Cascadia/Supplemental-Tables-US-only-revised-dec30-2020.xlsx) | | [Reidel et al. (2018)](https://www.nature.com/articles/s41467-018-05736-x), data come from the supplementary data 2 and these data are contained within the Merle et al. (2021) dataset |
| Habitat | NOAA | [Methane Bubble Streams](https://www.pmel.noaa.gov/eoi/Cascadia/Supplemental-Tables-US-only-revised-dec30-2020.xlsx) | | [Johnson et al. (2015)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2015GC005955), data come from the supporting information document (see S2 and S3) and while these data are contained within the Merle et al. (2021) dataset, S3 does not contain any sites that fall within Oregon call areas |
| Habitat | USGS | Rainier (H13118 (2018) | | Data came ahead of a 2019 EXPRESS cruise aboard the NOAA Ship Lasker (RL-19-05). [Nancy Prouty](nprouty@usgs.gov) at USGS shared these unpublished location data with [Curt Whitmire](curt.whitmire@noaa.gov) |
| Species | NOAA | [Marine seabird density](https://www.ncei.noaa.gov/archive/archive-management-system/OAS/bin/prd/jquery/download/242882.1.1.tar.gz) | [Metadata](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:0242882;view=iso) | These data were combined with vulnerability factors as detailed in [Adams et al. (2017)](https://pubs.usgs.gov/of/2016/1154/ofr20161154.pdf) and [Kelsey et al. (2018)](https://www.sciencedirect.com/science/article/abs/pii/S0301479718309228?via%3Dihub); option for downloading particular data is accessible through the [HTTPS](https://www.nodc.noaa.gov/archive/arc0193/0242882/) |
| Species | USGS | [Population vulnerability](https://www.sciencebase.gov/catalog/item/592f05a2e4b0e9bd0ea793df), [Collision vulnerability](https://www.sciencebase.gov/catalog/item/58f80528e4b0b7ea5451fcaf), [Displacement vulnerability](https://www.sciencebase.gov/catalog/item/592efde1e4b0e9bd0ea7939c) | These data are from the [Adams et al. (2017) paper](https://pubs.usgs.gov/of/2016/1154/ofr20161154.pdf) and used by [Kelsey et al. (2018)](https://www.sciencedirect.com/science/article/abs/pii/S0301479718309228?via%3Dihub)

##### *Fisheries Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|

##### *Wind Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|

#### Data commentary
Datasets explored but not included in analyses due to not located geographically in study area:
- [BOEM Active Lease Areas](https://www.data.boem.gov/Main/Mapping.aspx#ascii) ([Geodatabase download link](https://www.data.boem.gov/Mapping/Files/ActiveLeasePolygons.gdb.zip),[Shapefile download link](https://www.data.boem.gov/Mapping/Files/actlease.zip), [Metadata](https://www.data.boem.gov/Mapping/Files/actlease_meta.html))
- [Anchorage Areas](https://marinecadastre.gov/downloads/data/mc/Anchorage.zip) ([Metadata](https://www.fisheries.noaa.gov/inport/item/48849))
- [BOEM Lease Blocks](https://www.data.boem.gov/Mapping/Files/Blocks.gdb.zip) ([Metadata](https://www.data.boem.gov/Mapping/Files/blocks_meta.html))
- [Lightering Zones](https://marinecadastre.gov/downloads/data/mc/LighteringZone.zip) ([Metadata](https://www.fisheries.noaa.gov/inport/item/66149), [more information](https://www.govinfo.gov/content/pkg/CFR-2018-title33-vol2/xml/CFR-2018-title33-vol2-part156.xml#seqnum156.300)) - [Pipelines](https://www.data.boem.gov/Mapping/Files/Pipelines.gdb.zip) ([Option page](https://www.data.boem.gov/Main/Mapping.aspx#ascii), [Metadata](https://www.data.boem.gov/Mapping/Files/ppl_arcs_meta.html))
- [Shipping Lanes](http://encdirect.noaa.gov/theme_layers/data/shipping_lanes/shippinglanes.zip) (Federal)
- [Unexploded ordnances](https://marinecadastre.gov/downloads/data/mc/UnexplodedOrdnance.zip) (Points and areas, [metadata](https://www.fisheries.noaa.gov/inport/item/66208))
- [BOEM Drilling Platforms](https://www.data.boem.gov/Mapping/Files/Platforms.gdb.zip) ([Metadata](https://www.data.boem.gov/Mapping/Files/platform_meta.html), [Mapping Page](https://www.data.boem.gov/Main/Mapping.aspx#ascii), [Alternative Platform Structure dataset](https://www.data.boem.gov/Platform/PlatformStructures/Default.aspx))


#### Methodologies
While most data used in the model received a single value, some ranged between 0 and 1. This caused at times a hex cells across the call areas to have more than a single value due to data not sharing the exact same shape and size as the call are hex cells. When this occurred, the analysis chose the minimum value occurring in the hex cell. The minimum value prioritized conservation.

Data examined but not existing within original region
1. Environmental sensors and buoys
2. WWTF outfall structures
3. Ocean disposal sites
4. Special use airspace
5. Cod spawning protection areas
6. VTR (charter / party)
7. Known cod spawning areas

Data examined but not existing within -20m and -40m of federal waters
1. Wastewater outfall structures
2. Ocean disposal
3. Special use airspace
4. VTR (charter / party)
5. Cod spawning protection areas
6. Known cod spawning areas

Submodels
* National Security: currently integrates two datasets (unexploded ordnance areas and military operating areas) for three layers were aimed to get integrated in the submodel, however, no special use airspace overlapped with the Westport study region.

* Fisheries: four datasets integrated in model (VMS [all fishing (2015-2016)], VMS [all fishing under 4 / 5 knots(2015-2016)], VTR [all gear types], large pelagic survey [2012 - 2021])

* Natural and cultural resources
