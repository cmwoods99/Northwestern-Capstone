library(tidyverse)
library(hash)
library(readxl)
library(tableone)
library(table1)


# dataLoad ----------------------------------------------------------------

#read in elements
dfOrig <- read_csv('allElems_oig.csv') %>% 
  filter(CURROPER==1)

#read in dataDict
dfDict <- read_xlsx('dataDict_orig.xlsx',sheet = 'data_dictionary')

Dict <- dfDict %>% 
  select(`VARIABLE NAME`,`NAME OF DATA ELEMENT`) %>% 
  na.omit()


dataDict <- hash(keys=Dict$`VARIABLE NAME`,values=Dict$`NAME OF DATA ELEMENT`)

origDataSummary <- CreateTableOne(data = dfOrig)

continuousVars <- as_tibble(rownames_to_column(as.data.frame(origDataSummary$ContTable$Overall),var='variable'))
catVars <-  as_tibble(rownames_to_column(as.data.frame(origDataSummary$CatTable$Overall$COUNT_NWNE_P10),var='variable'))
  

# academics offered -------------------------------------------------------
#program Pct of Body
dfProgramPct <- dfOrig %>% 
  select(UNITID,starts_with('PCIP')) %>% 
  gather(starts_with('PCIP'),key='FieldOfStudy',value='pctBodyStudy') %>% 
  mutate_at(.vars=vars(pctBodyStudy),.funs=funs(as.numeric)) %>% 
  write_csv('fieldOfStudy.csv')

#data dictionary of fields
dictFields <- dfProgramPct %>% select(FieldOfStudy) %>% distinct()%>% pull()



#program Type Offered (associates, bachelors, certificate)
dfProgType <- dfOrig %>% 
  select(UNITID,starts_with('CIP')) %>%
  gather(starts_with('CIP'),key= 'typeProgram',value='offered')

  #merge 1, 2, 4 year certificate programs to general Certificate program
  dfCerts <- dfProgType %>% 
    filter(str_detect(typeProgram,'CERT')) %>% 
    mutate(typeProgram=str_replace(typeProgram,'CERT\\d','CERT')) %>% 
    distinct() %>% 
    arrange(UNITID,-offered) %>% 
    group_by(UNITID,typeProgram) %>% 
    filter(row_number()==1) %>% 
    ungroup()

  
  #cleaned program type
  dfProgTypeCN <- dfCerts %>% 
    bind_rows(dfProgType %>% filter(!str_detect(typeProgram,'CERT'))) %>% 
    write_csv('programTypeOfStudy.csv')
  
  
#data dictionary of programs of fields to study, 
  #*certificates merged**
dictProgramFields <-   dfProgTypeCN %>% select(typeProgram) %>% distinct() %>% pull 
dictProgramCERTFields <- dictProgramFields[str_detect(dictProgramFields,pattern = 'CERT')]
dictProgramFields <- dictProgramFields[!str_detect(dictProgramFields,pattern = 'CERT')]
dfProgTypeCN %>% select(typeProgram)
  

# race/sex/student count ------------------------------------------------------------

  #keep only new data, remove 2000 and 2009 data
dfSex <- dfOrig %>% 
  select(UNITID,UGDS,FEMALE,UGDS_MEN,UGDS_WOMEN) %>% 
  mutate_all(.,as.numeric) %>% 
  gather(FEMALE,UGDS_MEN,UGDS_WOMEN,key='Sex',value='pctGender') %>% 
  write_csv('gender.csv')

dfSexNAs <- dfOrig %>% 
  select(UNITID,UGDS,FEMALE,UGDS_MEN,UGDS_WOMEN) %>% 
  mutate_all(.,as.numeric) %>% 
  filter_all(any_vars(is.na(.))) %>% 
  tally() %>% pull

  
  
dfRace <- dfOrig %>% 
  select(UNITID,starts_with('UGDS'),-UGDS_AIANOLD,-UGDS_HISPOLD,-UGDS_MEN,-UGDS_WOMEN,-UGDS) %>% 
  mutate_all(.,as.numeric) %>% 
  gather('UGDS_WHITE':'UGDS_API',key='Race',value='pctRace') %>% 
  write_csv('race.csv')

  dfRaceNAs <- dfOrig %>% 
    select(UNITID,starts_with('UGDS'),-UGDS_AIANOLD,-UGDS_HISPOLD,-UGDS_MEN,-UGDS_WOMEN,-UGDS) %>% 
    mutate_all(.,as.numeric) %>% 
    filter_all(any_vars(is.na(.))) %>% 
    tally() %>% pull


#what's missing?
dfRace %>% 
  rename(.,ID=Race) %>% 
  group_by(ID) %>% 
  filter(is.na(pctRace)) %>% 
  tally() %>% 
  bind_rows(dfSex %>% 
              rename(.,ID=Sex) %>% 
              group_by(ID) %>% 
              filter(is.na(pctGender)) %>% 
              tally()) %>% 
  write_csv('NAs_Race_sex.csv')

read_csv('NAs_Race_sex.csv')

dictRaceFields <-dfRace %>% select(Race) %>% distinct() %>% pull
dictSexFields <-dfSex %>% select(Sex) %>% distinct() %>% pull
dictDemographics <- c(dictRaceFields,dictSexFields)

# financial profile -------------------------------------------------------
  #student body makeup of house income
dfIncBins <- dfOrig %>% 
  select(UNITID,contains('INC_PCT')) %>%
  mutate_all(.funs = as.numeric) %>% 
    gather('INC_PCT_LO':'IND_INC_PCT_H2',key='income_group',value='pctIncBody') %>% 
    mutate(tier=income_group %>% str_sub(start = str_count(.)-1,end = str_count(.)-1),
           dependent=income_group %>% str_sub(start = 1,end = 3))

#just income, no categories
dfInc <- dfIncBins %>% 
  filter(dependent=="INC")

#income with categories
dfIncCat <- dfIncBins %>% 
  filter(dependent!="INC")

dfIncNAs <- dfIncBins %>% 
  select(-tier,-dependent) %>% 
  spread(income_group,pctIncBody) %>% 
  filter_all(any_vars(is.na(.))) %>% 
  tally() %>% pull

dfIncCatNAs <- dfIncCat %>% 
  select(-tier,-dependent) %>% 
  spread(income_group,pctIncBody) %>% 
  filter_all(any_vars(is.na(.))) %>% 
  tally() %>% pull

#what's missing?
dfInc %>% 
  filter(is.na(pctIncBody)) %>% 
  group_by(income_group) %>% 
  tally() %>% 
  write_csv('NAs_Income.csv')

dfIncCat %>% 
  filter(is.na(pctIncBody)) %>% 
  group_by(income_group) %>% 
  tally() %>% 
  write_csv('NAs_CatsIncome.csv')


#group by the institution, fill in bad data with average split remaining
IncNAs <- dfInc %>% 
  group_by(UNITID,dependent) %>% 
  filter(is.na(pctIncBody)) %>% 
  tally()

#data cleaning to fill in evenly
filler <- dfInc %>% 
  group_by(UNITID,dependent) %>% 
  filter(!is.na(pctIncBody)) %>% 
  summarise(sm=1-sum(as.numeric(pctIncBody))) %>% 
  inner_join(.,IncNAs,by=c('UNITID'='UNITID')) %>% 
  mutate(remainingProp=sm/n) %>% 
  select(UNITID,dependent.x,remainingProp)

#cleaned
dfIncBinsCN <- dfInc %>% 
  inner_join(filler,by = c('UNITID'='UNITID','dependent'='dependent.x')) %>% 
  mutate(pctIncBody=if_else(is.na(pctIncBody),remainingProp,pctIncBody)) %>% 
  select(UNITID:dependent) %>%
  group_by(UNITID,income_group,tier, dependent) %>% 
  summarise(totaPctIncBody=sum(pctIncBody)) %>% 
  write_csv('studentBodyGenericIncomeProfile.csv')

#post clean NAs
dfIncBinsCNpost <- dfInc %>% 
  inner_join(filler,by = c('UNITID'='UNITID','dependent'='dependent.x')) %>% 
  mutate(pctIncBody=if_else(is.na(pctIncBody),remainingProp,pctIncBody)) %>% 
  select(UNITID:dependent) %>%
  group_by(UNITID) %>% 
  summarise(totaPctIncBody=sum(pctIncBody)) %>% 
  filter_all(any_vars(is.na(.)))

IncCatNAs <- dfIncCat %>% 
  group_by(UNITID) %>% 
  filter(is.na(pctIncBody)) %>% 
  tally()

#data cleaning to fill in evenly
filler <- dfIncCat %>% 
  group_by(UNITID) %>% 
  filter(!is.na(pctIncBody)) %>% 
  summarise(sm=2-sum(as.numeric(pctIncBody))) %>% 
  inner_join(.,IncCatNAs,by=c('UNITID'='UNITID')) %>% 
  mutate(remainingProp=sm/n) %>% 
  select(UNITID,remainingProp)

#cleaned
dfIncCatBinsCN <- dfIncCat %>% 
  left_join(filler,by = c('UNITID'='UNITID')) %>% 
  mutate(pctIncBody=if_else(is.na(pctIncBody),remainingProp,pctIncBody)) %>% 
  select(UNITID:dependent) %>%
  group_by(UNITID,income_group,tier, dependent) %>% 
  summarise(totaPctIncBody=sum(pctIncBody)) %>% 
  write_csv('studentBodyCategoryIncomeProfile.csv')

  
dfIncCatBinsCN %>% 
  bind_rows(dfIncBinsCN) %>% 
  spread(key = income_group,value = totaPctIncBody)

#postCleaning NAs
categoryNAs <- dfIncCat %>% 
  left_join(filler,by = c('UNITID'='UNITID')) %>% 
  mutate(pctIncBody=if_else(is.na(pctIncBody),remainingProp,pctIncBody)) %>% 
  select(UNITID:dependent) %>%
  group_by(UNITID) %>% 
  summarise(totaPctIncBody=sum(pctIncBody)) %>% 
  filter_all(any_vars(is.na(.)))



  dfIncBinsClned <- dfIncBinsCN %>% 
    spread(key = income_group,value = totaPctIncBody)
  dictIncPct <- dfIncBinsCN %>% select(income_group) %>% distinct() %>% pull
  
  #student body summary income
  
  dfIncomeSource <- dfOrig %>% 
    select(UNITID,DEP_INC_N,IND_INC_N,INC_N) %>%
    mutate_all(as.numeric) %>% 
    mutate(pctDep=DEP_INC_N/INC_N,
           pctIndep=1-pctDep) %>% 
    gather('pctDep','pctIndep',key = 'incomeLabel',value='pct') %>%
    select(UNITID,incomeLabel,pct) %>% 
    write_csv('IncomeSrce.csv')
  
dfMissingInc <-   dfIncomeSource %>% 
    spread(incomeLabel,pct) %>% 
    filter_all(any_vars(is.na(.)))
  
  dfHHInc <- dfOrig %>% 
    select(UNITID,FAMINC,MD_FAMINC,MEDIAN_HH_INC,FAMINC_IND) %>%
    mutate_all(as.numeric) %>% 
    gather('FAMINC','MD_FAMINC','FAMINC_IND','MEDIAN_HH_INC',key='HouseIncomeStats',value='incValue') %>% 
    write_csv('householdSalary.csv')
  
dfMissingSalaries <- dfOrig %>% 
    select(UNITID,FAMINC,MD_FAMINC,MEDIAN_HH_INC,FAMINC_IND) %>%
    mutate_all(as.numeric) %>% 
    filter_all(any_vars(is.na(.)))

summary(CreateTableOne(data=dfMissingSalaries))

dfHHInc <- dfOrig %>% 
  select(UNITID,FAMINC,MD_FAMINC) %>%
  mutate_all(as.numeric) %>% 
  gather('FAMINC','MD_FAMINC',key='HouseIncomeStats',value='incValue') %>% 
  write_csv('householdSalary.csv')

dfMissingSalaries <- dfOrig %>% 
  select(UNITID,FAMINC,MD_FAMINC) %>%
  mutate_all(as.numeric) %>% 
  filter_all(any_vars(is.na(.)))

summary(CreateTableOne(data=dfMissingSalaries))

  dictSalaries <- dfHHInc %>% select(HouseIncomeStats) %>% distinct() %>% pull
  dictIncomeSourceSplit <- dfIncomeSource %>% select(incomeLabel) %>% distinct() %>% pull  
  dictIncomeOfHousehold <- c(dictSalaries)

# school type -------------------------------------------------------------
#get the school types for minorities, gender, and religion into a dataframe
  schoolTypes=str_split('HBCU,PBI,ANNHI,TRIBAL,AANAPII,HSI,NANTI,MENONLY,WOMENONLY,RELAFFIL',',')[[1]]
  
  dfMinoriySchools <- dfOrig %>% 
    select(UNITID,schoolTypes[1:7]) %>% 
    mutate_all(as.numeric) %>% 
    replace(., is.na(.), 0) %>% 
    gather(schoolTypes[1:7],key='minorityGrouped',value='served') %>%  
    write_csv('minoritySchool.csv')
  
  
  dfGenderOnlySchool <- dfOrig %>% 
    select(UNITID,schoolTypes[8:9]) %>% 
    mutate_all(as.numeric) %>% 
    replace(., is.na(.), 0) %>% 
    gather(schoolTypes[8:9],key='genderGroup',value='genderBool') %>%  
    write_csv('genderOnlySchool.csv')
  
  dfSchoolTypes <- dfOrig %>% 
    select(UNITID,schoolTypes[10]) %>% 
    mutate_all(as.numeric) %>% 
    replace(., is.na(.), -1) %>% 
    write_csv('religiousSchool.csv')

  dictSpecialSchols <- schoolTypes

# cost --------------------------------------------------------------------
  costs=str_split('COSTT4_A,COSTT4_P,TUITIONFEE_IN,TUITIONFEE_OUT,TUITIONFEE_PROG,NPT4_PUB,NPT4_PRIV,NPT4_PROG,NPT4_OTHER',',')[[1]]
  dfCosts <- dfOrig %>% 
    select(UNITID,costs) %>% 
    gather(costs[1:2],key='programType',value='avgCostPerYear') %>% 
    gather(costs[3:5],key='tuition_InState',value='stateTuition') %>% 
    gather(costs[6:length(costs)],key='titleIVCosts',value='titleIVTuition')
    dictCosts <- costs

    dfProgramCosts <- dfOrig %>% 
      select(UNITID,costs[1:2]) %>%
      mutate_all(as.numeric) %>% 
      gather(costs[1:2],key='programType',value='avgCostPerYear') %>% 
      write_csv('programCosts.csv')
    
   dfMissingCostsProgram <-  dfOrig %>% 
      select(UNITID,costs[1:2]) %>%
      mutate_all(as.numeric) %>% 
      mutate(isNA=ifelse(is.na(COSTT4_A) & is.na(COSTT4_P),1,0)) %>% 
      filter(isNA==1)
    
    
    dfInStateOutTuition <- dfOrig %>% 
      select(UNITID,costs[3:5]) %>% 
      mutate_all(as.numeric) %>% 
      gather(costs[3:5],key='tuition_InState',value='stateTuition') %>% 
      write_csv('inStateOutStateCosts.csv')
    
    dfMissingStateTuition <- dfOrig %>% 
      select(UNITID,costs[3:5]) %>% 
      mutate_all(as.numeric) %>% 
      mutate(isNA=ifelse(is.na(TUITIONFEE_IN) & is.na(TUITIONFEE_OUT)& is.na(TUITIONFEE_PROG),1,0)) %>% 
      filter(isNA==1)
    
    dfLoansAcceptable <- dfOrig %>% 
      select(UNITID,costs[6:length(costs)]) %>% 
      mutate_all(as.numeric) %>% 
      gather(costs[6:length(costs)],key='titleIVCosts',value='titleIVTuition') %>% 
      write_csv('titleIVCosts.csv')
    
# earnings ----------------------------------------------------------------
  earnings=str_split(str_replace_all('COUNT_ED,COUNT_NWNE_P10,COUNT_WNE_P10,MN_EARN_WNE_P10,
MD_EARN_WNE_P10,PCT10_EARN_WNE_P10,PCT25_EARN_WNE_P10,PCT75_EARN_WNE_P10,PCT90_EARN_WNE_P10,
SD_EARN_WNE_P10,COUNT_WNE_MALE0_P10,COUNT_WNE_MALE1_P10,MN_EARN_WNE_INDEP0_P10,
MN_EARN_WNE_INDEP1_P10,MN_EARN_WNE_MALE0_P10,MN_EARN_WNE_MALE1_P10
',"[\r\n]", ""),',')[[1]]
  dfEarnings <- dfOrig %>% 
    select(UNITID,earnings) %>% 
    gather(earnings[4:10],key='collectedStats',value='earnStat') %>% 
    gather(earnings[13:14],key='wasDependent',value='earnings') %>% 
    gather(earnings[15:16],key='genderEarn',value='genderEarnings') %>% 
    select(-COUNT_NWNE_P10,-COUNT_WNE_P10,-COUNT_WNE_MALE0_P10,-COUNT_WNE_MALE1_P10) 
  dictEarnings <- earnings
  

  
  dfpctEmployed <- dfOrig %>% 
    select(UNITID,COUNT_NWNE_P10,COUNT_NWNE_P10,COUNT_WNE_P10,COUNT_WNE_MALE0_P10,COUNT_WNE_MALE1_P10) %>% 
    mutate(PctWorking=as.numeric(COUNT_WNE_P10)/(as.numeric(COUNT_NWNE_P10)+as.numeric(COUNT_WNE_P10)),
           PctWomenWorking=(as.numeric(COUNT_WNE_MALE0_P10)/(as.numeric(COUNT_NWNE_P10)+as.numeric(COUNT_WNE_P10))),
           pctMenWorking=(as.numeric(COUNT_WNE_MALE1_P10)/(as.numeric(COUNT_NWNE_P10)+as.numeric(COUNT_WNE_P10)))) %>% 
    select(UNITID,PctWorking,pctMenWorking,PctWomenWorking) %>% 
    write_csv('pctEmployed_WgenderSplit.csv')
  
  dfpctEmployed %>% 
    filter(is.na(PctWorking))
    
  dfpctEmployed %>% 
    filter(is.na(pctMenWorking))
  
  
  dictPctEmployed <- dfpctEmployed %>% names()
  
  dfpctileEarn <- dfOrig %>% 
    select(UNITID,earnings[4:10]) %>% 
    mutate_all(as.numeric) %>% 
    gather(earnings[4:10],key='pctileEarnings',value='pctEarnStat') %>% 
    write_csv('pctileEarnings.csv')
  
  summary(CreateTableOne(data=dfOrig %>% 
    select(UNITID,earnings[4:10]) %>% 
    mutate_all(as.numeric))) 
  
  dfIncDepend <-  dfOrig %>% 
    select(UNITID,earnings[13:14]) %>% 
    gather(earnings[13:14],key='wasDependent',value='depEarn') %>%
    mutate_at(.vars=vars(depEarn),.funs=funs(as.numeric)) %>% 
    write_csv('incDepEarnings.csv')

  dfEarningsGender<-  dfOrig %>% 
    select(UNITID,earnings[15:16]) %>% 
    gather(earnings[15:16],key='genderEarn',value='genderEarnings') %>%
    mutate_at(.vars=vars(genderEarnings),.funs=funs(as.numeric)) %>% 
    write_csv('genderEarnings.csv')
  

# retention Rate ----------------------------------------------------------

retentionFields=str_split(str_replace_all('RET_FT4_POOLED,RET_FTL4_POOLED,RET_PT4_POOLED,RET_PTL4_POOLED',"[\r\n]", ""),',')[[1]]
dfRetentionData <-   dfOrig %>% 
    select(UNITID,retentionFields) %>%
    mutate_all(as.numeric) %>% 
    write_csv('retentionInfo.csv')
dictRet  <- retentionFields
  
  
# broad school info -------------------------------------------------------
  #location, type of institution
schoolInfo=str_split(str_replace_all('INSTNM,CITY,STABBR,ZIP,ACCREDAGENCY,INSTURL,NPCURL,SCH_DEG,HCM2,
PREDDEG,HIGHDEG,CONTROL,ST_FIPS,REGION,LOCALE,LOCALE2,CCBASIC,UGDS,UG',"[\r\n]", ""),',')[[1]]
dfSchoolInfo <- dfOrig %>% 
  select(UNITID,schoolInfo) %>%
  write_csv('generalSchoolInfo.csv')
dictSchoolInfo=schoolInfo

allDicts <- c(dictCosts,dictDemographics,dictEarnings,dictFields,dictSalaries,
  dictIncPct,dictSchoolInfo,dictSpecialSchols,dictRet,dictProgramFields) %>% unique()

dictManufactured <- c(dictPctEmployed,dictIncomeSource,dictProgramCERTFields)

keys=keys(dataDict[allDicts])
Dict <- Dict %>% 
  rename(value=`VARIABLE NAME`)
as_tibble(keys) %>% 
  inner_join(.,Dict) %>% 
  bind_rows(tibble(value=dictManufactured,
                   `NAME OF DATA ELEMENT`  =c("percent working 10 years following graduation",
                                              "percent men working 10 years following graduation",
                                              "percent women working 10 years following graduation",
                                              "percent from dependent incomes",
                                              "percent from independent incomes"))) %>% 
  write_csv('newDictionary.csv')




# populate all new data ---------------------------------------------------

dfNewData <- dfProgramPct %>% ungroup() %>% 
  spread(FieldOfStudy,pctBodyStudy) %>% 
  inner_join(.,
             dfProgTypeCN %>% 
               ungroup() %>% 
               spread(typeProgram,offered)) %>% 
  inner_join(.,
             dfSex %>% 
               ungroup() %>% 
               spread(Sex,pctGender)) %>%
  inner_join(.,
             dfRace %>% 
               ungroup() %>% 
               spread(Race, pctRace)) %>% 
  inner_join(.,
             dfIncBinsCN %>% 
               ungroup() %>% 
               select(-tier,-dependent) %>% 
               spread(income_group,totaPctIncBody)) %>% 
  inner_join(.,
             dfIncCatBinsCN %>% 
               ungroup() %>% 
               select(-tier,-dependent) %>% 
               spread(income_group,totaPctIncBody)) %>% 
  inner_join(.,
             dfIncomeSource %>% 
               ungroup() %>% 
               spread(incomeLabel,pct)) %>% 
  inner_join(.,
             dfHHInc %>% 
               ungroup() %>% 
               spread(HouseIncomeStats,incValue)) %>% 
  inner_join(.,
             dfMinoriySchools %>%
               ungroup() %>% 
               spread(minorityGrouped,served)) %>% 
  inner_join(.,
             dfSchoolTypes) %>% 
  inner_join(.,
             dfGenderOnlySchool %>%
               ungroup() %>% 
               spread(genderGroup,genderBool)) %>% 
  inner_join(.,
             dfProgramCosts %>%
               ungroup() %>% 
               spread(programType,avgCostPerYear)) %>% 
  inner_join(.,
             dfInStateOutTuition %>%
               ungroup() %>% 
               spread(tuition_InState,stateTuition)) %>% 
  inner_join(.,
             dfLoansAcceptable %>%
               ungroup() %>% 
               spread(titleIVCosts,titleIVTuition)) %>% 
  inner_join(.,
             dfpctEmployed) %>% 
  inner_join(.,
             dfpctileEarn %>%
               ungroup() %>% 
               spread(pctileEarnings,pctEarnStat)) %>% 
  inner_join(.,
             dfIncDepend %>%
               ungroup() %>% 
               spread(wasDependent,depEarn)) %>% 
  inner_join(.,
             dfEarningsGender %>%
               ungroup() %>% 
               spread(genderEarn,genderEarnings)) %>% 
  inner_join(.,dfRetentionData) %>% 
  inner_join(.,dfSchoolInfo,by=('UNITID'='UNITID')) %>% 
  write_csv('allDataCleaned.csv')



# EDA ---------------------------------------------------------------------
library(ggplot2)
library(ggpubr)
library(vcd)
library(viridis)

theme_set(theme_pubr())

#get category labels from dictionary
dfLabels <- dfDict %>% 
  select(`VARIABLE NAME`,VALUE,LABEL) %>% 
  mutate(VARIABLE=`VARIABLE NAME`) %>% 
  select(-`VARIABLE NAME`) %>% 
  filter(!is.na(VALUE)) %>%
  fill(VARIABLE,.direction = c('down')) %>% 
  mutate(ky=str_c(VARIABLE,VALUE)) %>% 
  na.omit()


labelDict <- hash(keys=dfLabels$VARIABLE,values=dfLabels$LABEL)


#institutions info 

dfInstitutionLabels <- dfSchoolInfo %>% 
  select(UNITID,PREDDEG,HIGHDEG,CONTROL) %>%
  gather(PREDDEG,HIGHDEG,CONTROL,key = "VARIABLE",value = 'VALUE') %>% 
  inner_join(dfLabels) %>% 
  select(-ky,-VALUE) %>% 
  spread(VARIABLE,LABEL)

#distrib
dfInstitutionLabels %>% 
  select(PREDDEG,HIGHDEG,CONTROL) %>%
  group_by(CONTROL,HIGHDEG) %>% 
  tally() %>% 
  
  ggplot(., aes(x = factor(HIGHDEG), y = n))+
  geom_bar(
    aes(fill = factor(HIGHDEG)), stat = "identity", color = "white",
    position = position_dodge(0.9)
  )+
  facet_wrap(~CONTROL) +
  scale_color_viridis(discrete = TRUE, option = "viridis")+
  scale_fill_viridis(discrete = TRUE,option = 'viridis')+
  #fill_palette("jco")+
  
  theme_pubr()+
  theme(axis.text.x=element_blank(),
        axis.title.x = element_blank(),
        legend.title = element_blank())

#distrib
dfInstitutionLabels %>% 
  select(PREDDEG,HIGHDEG,CONTROL) %>%
  group_by(CONTROL,HIGHDEG) %>% 
  tally() %>% 
  
  ggplot(., aes(x = factor(HIGHDEG), y = n))+
  geom_bar(
    aes(fill = factor(HIGHDEG)), stat = "identity", color = "white",
    position = position_dodge(0.9)
  )+
  facet_wrap(~CONTROL) +
  scale_color_viridis(discrete = TRUE, option = "viridis")+
  scale_fill_viridis(discrete = TRUE,option = 'viridis')+
  #fill_palette("jco")+
  
  theme_pubr()+
  theme(axis.text.x=element_blank(),
        axis.title.x = element_blank(),
        legend.title = element_blank())


  
#stacked bar
dfInstitutionLabels %>% 
  select(PREDDEG,HIGHDEG,CONTROL) %>%
  group_by(CONTROL,HIGHDEG) %>% 
  tally() %>% 
ggplot(., aes(x = CONTROL, y = n)) +
  geom_bar(
    aes(color = HIGHDEG, fill = HIGHDEG),
    stat = "identity", position = position_stack()
  ) +
  scale_color_viridis(discrete = TRUE, option = "viridis")+
  scale_fill_viridis(discrete = TRUE,option = 'viridis')+
  theme_pubr()+
  theme(
        axis.title.x = element_blank(),
        legend.title = element_blank())


dfLabels <- dfDict %>% 
  select(`VARIABLE NAME`,VALUE,LABEL) %>% 
  mutate(VARIABLE=`VARIABLE NAME`) %>% 
  select(-`VARIABLE NAME`) %>% 
  filter(!is.na(VALUE)) %>%
  fill(VARIABLE,.direction = c('down')) %>% 
  mutate(ky=str_c(VARIABLE,VALUE)) %>% 
  na.omit()

dfLabelsNoVals <- read_csv('newDictionary.csv')

library(ggridges)
library(dplyr)
library(forcats)
library(ggplot2)
library(ggpubr)
library(tidyquant)

#cost of Loans
dfLoansAcceptable %>% 
  mutate(titleIVTuition=as.numeric(titleIVTuition)) %>% 
  filter(!is.na(titleIVTuition)) %>% 
  ggplot(.,aes(y=titleIVCosts))+
  theme_pubr()+
  scale_fill_viridis_d()+
  geom_density_ridges(
    aes(x = titleIVTuition, fill = titleIVCosts), 
    alpha = .6, color = "white"
  )+
  labs(
    x = "Costs for Loan programs",
    y = "Education Domain Type",
    title = "Costs for Loan Programs"
  )
  

#earnings by gender
dfEarningsGender %>% 
  mutate(gender=if_else(genderEarn=='MN_EARN_WNE_MALE0_P10','Female','Male')) %>% 
  select(-genderEarn) %>% 
  inner_join(dfInstitutionLabels) %>% 
  select(gender,genderEarnings,CONTROL) %>% 
  filter(!is.na(genderEarnings)) %>% 
  mutate(eduDomain=as.factor(CONTROL)) %>% 
  select(-CONTROL) %>% 
  ggplot(.,aes(y=eduDomain))+
  geom_density_ridges(
    aes(x = genderEarnings, fill = gender), 
    alpha = .6, color = "white"
  )+
  labs(
    x = "Earnings 10 years Post Graduation",
    y = "Education Domain Type",
    title = "Earnings by Gender",
    subtitle = "Compared by Education Control Type"
  )+
  scale_y_discrete(expand = c(0.01, 0)) +
  scale_x_continuous(expand = c(0.01, 0)) +
  scale_fill_cyclical(
    breaks = c("Female", "Male"),
    values = c("#ff0000", "#0000ff", "#ff8080", "#8080ff"),
    name = "Gender Pay", guide = "legend"
  )+
  theme_ridges(grid = FALSE)


#earnings cluster
library(factoextra)


matrix.please<-function(x) {
  m<-as.matrix(x[,-1])
  rownames(m)<-x[,1]
  m
}

dfClpctileEarn <- dfpctileEarn %>% 
 # filter(pctileEarnings=='MN_EARN_WNE_P10') %>%
  #select(-pctileEarnings) %>% 
  spread(pctileEarnings,pctEarnStat) %>% 
  select(-MD_EARN_WNE_P10) %>% 
  drop_na() %>% 
  as.data.frame(.)

row.names(dfClpctileEarn) <- dfClpctileEarn[,1]
mEarnScale <- scale(matrix.please(dfClpctileEarn))

fviz_nbclust(mEarnScale, kmeans, method = "wss") +
  geom_vline(xintercept = 6, linetype = 2)


set.seed(123)
km.res <- kmeans(mEarnScale, 6, nstart = 25)
earningsCluster <- as_tibble(rownames_to_column(cbind(as.data.frame(mEarnScale)
      ,cluster=km.res$cluster),var="UNITID"))

wCluster <- cbind(as.data.frame(mEarnScale)
      ,cluster=km.res$cluster)

source("https://bioconductor.org/biocLite.R")
biocLite("ComplexHeatmap")
library(circlize)
library(ComplexHeatmap)

Heatmap(wCluster[,-1], name = "cluster", split = wCluster$cluster,
        row_names_gp = gpar(fontsize = 7),
        column_names_gp = gpar(fontsize=8))

library(tidyverse)
library(tidyquant)

dfInStateOutTuition %>%
  filter(tuition_InState %in% c('TUITIONFEE_IN','TUITIONFEE_OUT')) %>% 
  mutate(stateTuition=as.numeric(stateTuition)) %>%
  filter(!is.na(stateTuition)) %>% 
  ggplot(aes(x=tuition_InState,y=stateTuition)) +
  geom_boxplot(aes(fill=tuition_InState))+
  labs(
    title='Tuition'
  )+
  theme_tq()+scale_fill_tq()+
  theme(axis.title.x  = element_blank(),
        axis.title.y = element_blank(),
        legend.title = element_blank())
  

dfSchoolInfo
