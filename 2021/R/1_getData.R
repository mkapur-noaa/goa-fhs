## download the raw data from Oracle and save
## based on data.R by Cole Monnahan
require(RODBC)
require(dplyr)
require(here)
require(ggplot2)
require(r4ss)
  
AFSC <- odbcConnect("AFSC","mkapur","N5w!Pw4mkq",  believeNRows = FALSE)
AKFIN <- odbcConnect("AKFIN","mkapur","ssmamk22",  believeNRows=FALSE)

species <- 10130
sp_area <- "'GOA'"

## dwnld catches ---- 
source("C:/Users/maia.kapur/Work/flathead_2021/newsbss/functions/get_catch.R")
fsh_sp_area <- "'CG','SE','WG','WY','EY'"
message("Querying AKFIN to get catch..")
catch <- GET_CATCH(fsh_sp_area=fsh_sp_area,
                   fsh_sp_label="'FSOL'",
                   final_year=2021,
                   ADD_OLD_FILE=FALSE)$CATCH
catch <- arrange(catch, YEAR, ZONE, GEAR1)
write.csv(catch, file=here('data',paste0(Sys.Date(),'-catch.csv') ), row.names=FALSE)


## manually download any needed years of weekly catches from 
## https://www.fisheries.noaa.gov/alaska/commercial-fishing/fisheries-catch-and-landings-reports-alaska#goa-groundfish

## dwnld survey dat ----
## need 2021 data input
## not req'd for partial update but possibly will use
test <- paste0("SELECT GOA.BIOMASS_TOTAL.YEAR as YEAR,\n ",
               "GOA.BIOMASS_TOTAL.TOTAL_BIOMASS as BIOM,\n ",
               "GOA.BIOMASS_TOTAL.TOTAL_POP as POP,\n ",
               "GOA.BIOMASS_TOTAL.BIOMASS_VAR as BIOMVAR,\n ",
               "GOA.BIOMASS_TOTAL.POP_VAR as POPVAR,\n ",
               "GOA.BIOMASS_TOTAL.HAUL_COUNT as NUMHAULS,\n ",
               "GOA.BIOMASS_TOTAL.CATCH_COUNT as NUMCAUGHT\n ",
               "FROM GOA.BIOMASS_TOTAL\n ",
               "WHERE GOA.BIOMASS_TOTAL.SPECIES_CODE in (",species,")\n ",
               "ORDER BY GOA.BIOMASS_TOTAL.YEAR")
index <- sqlQuery(AFSC, test)
if(!is.data.frame(index)) stop("Failed to query GOA survey data")
write.csv(index, here('data',paste0(Sys.Date(),'-index.csv') ),row.names=FALSE)



## Survey biomass by area
message("Querying survey biomass data...")
test <- paste0("SELECT GOA.BIOMASS_AREA.YEAR as YEAR,\n ",
               "GOA.BIOMASS_AREA.REGULATORY_AREA_NAME as AREA,\n",
               "GOA.BIOMASS_AREA.AREA_BIOMASS as BIOM,\n ",
               "GOA.BIOMASS_AREA.AREA_POP as POP,\n ",
               "GOA.BIOMASS_AREA.BIOMASS_VAR as BIOMVAR,\n ",
               "GOA.BIOMASS_AREA.POP_VAR as POPVAR,\n ",
               "GOA.BIOMASS_AREA.HAUL_COUNT as NUMHAULS,\n ",
               "GOA.BIOMASS_AREA.CATCH_COUNT as NUMCAUGHT\n ",
               "FROM GOA.BIOMASS_AREA\n ",
               "WHERE GOA.BIOMASS_AREA.SPECIES_CODE in (",species,")\n ",
               "ORDER BY GOA.BIOMASS_AREA.YEAR")
index_by_area <- sqlQuery(AFSC, test)
if(!is.data.frame(index_by_area))
  stop("Failed to query GOA survey data by area")
write.csv(index_by_area, here('data',paste0(Sys.Date(),'-index_by_area.csv') ), row.names=FALSE)


## attempt to dwnld age dat ----

message("Querying fishery ages files...")
SpeciesCode <- "103" #105 is rex sole
FmpArea <- "600 and 650"  ##Typical options are AI = 539-544, GOA = 600 to 699 (600-650 incl. all the management areas and 690 is outside the EEZ), BS = 500 to 539

saveRDS(AgeLength.df, file=here("data","2021-11-12-fishery_agecomps.RDS"))
# source('~/assessments/2021/BSAI-flathead/2020_files/data/get_agecomps_fishery.R')

