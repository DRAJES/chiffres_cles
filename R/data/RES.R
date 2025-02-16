{library(rgdal)
  library(leafpop)
  library(leaflet)
  library(leaflet.extras2)
  library(geosphere)
  library(sp)
  library(sf)
  library(maps)
  library(leaflet.providers) 
  library(leaflet.minicharts)
  library(readxl)
  library(raster)
  library(smoothr)
  library(rmapshaper)
  library(rpivotTable)
  library(foreign)
  library(osrm)
  library(ggmap)
  library(rpivotTable)
  library(fontawesome)
  library(tidyverse)
}
equipement <- read.csv2("I:/SUPPORT/04_STATS/Sources/MEDES/RES/2020/2020_Equipements.csv",as.is = T,encoding = "UTF-8")
codeequ <- read_excel("I:/SUPPORT/04_STATS/Sources/MEDES/RES/2020/2020-dictionnairevariablesres.xls",sheet = 2)
passage <-  read_excel("I:/SUPPORT/05_CARTO/Fonds de cartes/communes/table_passage_annuelle_2021.xlsx",sheet=1,skip=5)
                       
load("data/demo/basecom.RData")

proprio <- c("Etablissement privé commercial","Privé non commercial")
equip <- equipement %>% filter(ComInsee<"96000") %>% 
  filter(!EquipementCateg == "Nature") %>%
#  filter (!GestionTypeProprietairePrincLib %in% proprio) %>%
  dplyr::select(ComInsee,InsNom,EquNom,EquipementTypeCode,EquipementTypeLib, EquipementCateg,EquipementFamille,
         EquGPSX,EquGPSY, GestionTypeProprietairePrincLib,GestionTypeProprietaireSecLib,
         NatureLibelle,EquProximite,EquNatSurfaceBassin,EquNatProfMax,
         InsNumeroInstall,EquipementId,EquEclairage,EquERPCategorie,EquOuvertSaison) %>%
  mutate (ComInsee = case_when(
    ComInsee>"75100" & ComInsee<"75200" ~ "75056",
    ComInsee>"13200" & ComInsee<"13300" ~ "13055",
    ComInsee>"69300" & ComInsee<"69400" ~ "69123",
    TRUE ~ ComInsee) ) 
nature <- equipement %>% filter(ComInsee<"96000") %>% 
  filter(EquipementCateg == "Nature") %>%
  #  filter (!GestionTypeProprietairePrincLib %in% proprio) %>%
  dplyr::select(ComInsee,InsNom,EquNom,EquipementTypeCode,EquipementTypeLib, EquipementCateg,EquipementFamille,
         EquGPSX,EquGPSY, GestionTypeProprietairePrincLib,GestionTypeProprietaireSecLib,
         NatureLibelle,EquProximite,EquNatSurfaceBassin,EquNatProfMax,
         InsNumeroInstall,EquipementId,EquEclairage,EquERPCategorie,EquOuvertSaison) %>%
  mutate (ComInsee = case_when(
    ComInsee>"75100" & ComInsee<"75200" ~ "75056",
    ComInsee>"13200" & ComInsee<"13300" ~ "13055",
    ComInsee>"69300" & ComInsee<"69400" ~ "69123",
    TRUE ~ ComInsee) )
rm(proprio);rm(equipement)

equip <- equip %>% filter(!is.na(EquGPSX)) %>%
  left_join(.,passage %>% distinct(CODGEO_2014,.keep_all = T) %>%
              dplyr::select(CODGEO_2014,CODGEO_2021),by=c("ComInsee"="CODGEO_2014") )   %>%           
  left_join(.,basecom %>% dplyr::select (CODGEO_2021=1,LIBGEO,DEP,REG,EPCI,BV2022,P19_POP) ,by="CODGEO_2021")  %>%
 relocate(CODGEO_2021,REG,DEP,EPCI,BV2022,.before = ComInsee) %>%
  dplyr::select(REG,DEP,EPCI,BV2022,CODGEO_2021,LIBGEO,population=P19_POP,
         InsNom,EquNom,NatureLibelle,EquipementTypeLib,EquipementFamille,EquipementCateg,GestionTypeProprietairePrincLib,GestionTypeProprietaireSecLib,
         EquProximite,InsNumeroInstall,EquipementId,EquEclairage,EquERPCategorie,EquOuvertSaison,EquipementTypeCode, EquGPSX,EquGPSY)

equip27 <-  equip %>% dplyr::filter (EPCI %in% basecom$EPCI[basecom$REG=="27"] |
                 BV2022 %in% basecom$BV2022[basecom$REG=="27"]) 
 


nature <- nature %>% 
  left_join(.,passage %>% distinct(CODGEO_2014,.keep_all = T) %>%
              dplyr::select(CODGEO_2014,CODGEO_2021),by=c("ComInsee"="CODGEO_2014") )   %>%           
  left_join(.,basecom %>% dplyr::select (CODGEO_2021=1,LIBGEO,DEP,REG,EPCI,BV2022,P19_POP) ,by="CODGEO_2021")  %>%
  relocate(CODGEO_2021,REG,DEP,EPCI,BV2022,.before = ComInsee) %>%
  dplyr::select(REG,DEP,EPCI,BV2022,CODGEO_2021,LIBGEO,population=P19_POP,
         InsNom,EquNom,NatureLibelle,EquipementTypeLib,EquipementFamille,EquipementCateg,GestionTypeProprietairePrincLib,GestionTypeProprietaireSecLib,
         EquProximite,InsNumeroInstall,EquipementId,EquEclairage,EquERPCategorie,EquOuvertSaison,EquipementTypeCode, EquGPSX,EquGPSY)

nature27 <- nature %>% dplyr::filter (EPCI %in% basecom$EPCI[basecom$REG=="27"] |
                                        BV2022 %in% basecom$BV2022[basecom$REG=="27"]) 

save(equip,equip27,nature,nature27,file="data/sport/RES.RData")
