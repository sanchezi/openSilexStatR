#-------------------------------------------------------------------------------
# Program: outlierDetection.R
# Objective: functions for outliers detection according to biological meaning
# Author: I.Sanchez
# Creation: 05/09/2016
# Update: 26/05/2020
#-------------------------------------------------------------------------------

##' a function for several outlier criteria
##' @description this function calculates outlier criteria on plants for each parameter
##' @param datain input dataframe of parameters
##' @param typeD type of datain dataframe (1==wide, 2==long)
##' @param residin input dataframe of residuals
##' @param typeR type of residin dataframe (1==wide, 2==long)
##' @param trait character, trait of interest to model (example biovolume24, PH24 ...)
##' @param resRawName character, names of the raw residual in datain
##' @param resStdName character, names of the standardized residual in datain
##' @param threshold, numeric threshold for the normal quantile in raw criteria
##' @details This function needs in input a dataframe with residuals extracted from
##' a mixed linear model (for instance using asreml or nlme libraries) and an another dataframe
##' with the estimated parameters (biovolume, plantHeight, leafArea etc...). Several criteria
##' will be calculated using different types of residuals. The 2 input dataframe must contain
##' the following columns names: "experimentAlias","Line" and "Position".
##' \describe{
##' \item{raw  and quartile criteria}{use raw residuals}
##' \item{influence criterion}{uses standardized residuals}
##' }
##' The function must be executed for each parameter of interest: biovolume, plantHeight and phy.
##' Each criteria will be used according with some rules:
##' \describe{
##' \item{Small plant}{biovolume and phy}
##' \item{Big plants}{biovolume and plantHeight}
##' }
##' @return a dataframe with columns identifiying criteria used to detect outlier plants
##' with 1==plant OK - 0==plant KO to suppress
##' \describe{
##' \item{critraw}{raw criterion, critci: quartiles criterion}
##' \item{critinfl}{influence criterion with standardized residuals}
##' }
##'
##' @importFrom stats IQR qnorm quantile sd lm na.omit as.formula
##'
##' @examples
##' # Not run
##' # dt1<-outlierCriteria()
##'
##' @export
outlierCriteria<-function(datain,typeD,residin,typeR,trait,resRawName,resStdName,threshold){
  # Create a dataframe with raw data, fitted and residuals for each paramater
  datain<-as.data.frame(datain)
  if (typeD==1){ # wide format column==differents traits
    tmp1<-dplyr::select_(datain,"Ref","Genosce","Line","Position","genotypeAlias","experimentAlias",
                         "scenario","repetition","potAlias",trait)
  } else if (typeD==2){ # long format 1 column Trait, 1 column value
    tmp1<-dplyr::filter(datain, Trait==trait)
    tmp1<-dplyr::rename_(tmp1,trait="Trait")
  }
  residin<-as.data.frame(residin)
  if (typeR==1){ # wide format column==differents traits
    tmp2<-residin
  } else if (typeR==2){ # long format 1 column Trait, 1 column value
    tmp2<-dplyr::filter(residin, Trait==trait)
  }
  # merge datain and residin by experimentAlias, line and position (unique key)
  tmp<-dplyr::left_join(tmp1,tmp2,by=c("experimentAlias","Line","Position"))
  # mean and sd of residuals
  tmp<-dplyr::mutate(tmp, mean.res=mean(tmp[,resRawName],na.rm=TRUE),
                     sd.res=sd(tmp[,resRawName],na.rm=TRUE))
  #--- raw cleaning
  tmp<-dplyr::mutate(tmp, lower.res=mean.res - sd.res*qnorm(threshold),
                     upper.res=mean.res + sd.res*qnorm(threshold))
  tmp<-dplyr::mutate(tmp,lower.critraw=ifelse(tmp[,resRawName]-tmp[,"lower.res"]>0,yes=1,no=0),
                     upper.critraw=ifelse(tmp[,resRawName]-tmp[,"upper.res"]<0,yes=1,no=0))
  #--- Quantiles cleaning
  tmp<-dplyr::mutate(tmp, Q1.res=quantile(tmp[,resRawName],probs=0.25,na.rm=TRUE)-1.5*IQR(tmp[,resRawName],na.rm=TRUE),
                     Q3.res=quantile(tmp[,resRawName],probs=0.75,na.rm=TRUE)+1.5*IQR(tmp[,resRawName],na.rm=TRUE))
  tmp<-dplyr::mutate(tmp,lower.critci=ifelse(tmp[,resRawName]-tmp[,"Q1.res"]>0,yes=1,no=0),
                     upper.critci=ifelse(tmp[,resRawName]-tmp[,"Q3.res"]<0,yes=1,no=0))
  #--- influence with standardized residuals
  tmp<-dplyr::mutate(tmp,lower.critinfl=ifelse(tmp[,resStdName]>=-2,yes=1,no=0),
                     upper.critinfl=ifelse(tmp[,resStdName]<=2,yes=1,no=0))
  # output
  return(tmp)
}

#------------------- tutorial version
#' FuncDetectOutlierPlantMaize
#' @description function to detect plant outliers in a temporal lattice experiment 
#'       on Maize which can be extended to others experiment types. 
#'  The criteria needs 3 phenotypes (ex for maize: the estimated biomass, 
#'  plant height and phyllocron)
#'  Please, take a look of the structure of the example dataset: plant4
#'  \describe{
#'    \item{plants are identified as "small outlier plant"}{ if for biomass AND phyllocron
#'              res_i < mu_{res} - qnorm(threshold) * sd_{res}}  
#'    \item{plants are identified as "big outlier plant"}{ if for biomass AND plant height
#'              res_i > mu_{res} + qnorm(threshold) * sd_{res} } 
#'  }
#' @param datain input dataframe, a spatio-temporal data.frame
#' @param dateBeforeTrt character, date just before treatment in the experiment
#' @param param1 character, name of a phenotypic variable in datain (ex: Biomass)
#' @param param2 character, name of a phenotypic variable in datain (ex: plant height)
#' @param param3 character, name of a phenotypic variable in datain (ex: phyllocron)
#' @param paramGeno character, name of the genotype variable in datain
#' @param paramCol character, name of the Line variable in the datain
#' @param paramRow character, name of the position variable in datain
#' @param threshold numeric,
#' @param nCol numeric, nunber of lines in the lattice platform (28 for phenoarch)
#' @param nRow numeric, nunber of columns in the lattice platform (60 for phenoarch)
#' @param genotype.as.random logical, If TRUE, the genotype is included as random effect 
#'                            in the model. The default is FALSE. (see the SpATS() help)
#' @param timeColumn character, name of the time points column in datain (ex: Time)
#' 
#' @details see SpATS() from the SpATS R library
#' The input dataset must contain the following columns:
#'  In the case of a plant experiment in phenoarch platform
#' \describe{
#'  \item{1}{the estimated biomass, numeric}
#'  \item{2}{the estimated plant height, numeric}
#'  \item{3}{the estimated phyllocron, numeric}
#'  \item{4}{the genotype id, character}
#'  \item{5}{the lines in the greenhouse or lattice, numeric}
#'  \item{6}{the columns in the greenhouse or lattice, numeric}
#'  }
#'  In other kind of lattice platform
#'  \describe{
#'  \item{1}{param1 a numeric phenotypic parameter}
#'  \item{2}{param2 a numeric phenotypic parameter}
#'  \item{3}{param3 a numeric phenotypic parameter}
#'  \item{4}{the genotype id, character}
#'  \item{5}{the lines in the platform or lattice, numeric}
#'  \item{6}{the columns in the platform or lattice, numeric}
#' }
#'
#' @return return a list of 4 elements
#' \describe{
#'  \item{outputDataframe}{ a data.frame with the used data set, the fitted values 
#'                        and residuals calculated by the model, 
#'                        the flag of outliers}
#'  \item{smallOutlier}{a data.frame of the detected "small" outliers}
#'  \item{bigOutlier}{a data.frame of the detected "big" outliers}
#'  \item{m1}{A list of the SpATS results for param1 (see the SpATS() help)}
#'  \item{m2}{A list of the SpATS results for param2 (see the SpATS() help)}
#'  \item{m3}{A list of the SpATS results for param3 (see the SpATS() help)}
#' }
#' 
#' @importFrom SpATS SpATS PSANOVA
#' @importFrom dplyr filter mutate
#' 
#' @examples
#' \donttest{
#' test<-FuncDetectOutlierPlantMaize(datain=phenoarchToy,dateBeforeTrt="2017-04-27",
#'                 param1="Biomass_Estimated",param2="Height_Estimated",
#'                 param3="phyllocron",paramGeno="Geno",
#'                 paramCol="Line",paramRow="Position",
#'                 threshold=0.95,nCol=28,nRow=60,genotype.as.random=FALSE,
#'                 timeColumn = "Time")
#' plot(test$m1)  
#' plot(test$m2)  
#' plot(test$m3) 
#' ggplot(data=test$outputDataframe,aes(x=fittedP1,y=devResP1)) + geom_point()
#' ggplot(data=test$outputDataframe,aes(x=fittedP2,y=devResP2)) + geom_point()
#' ggplot(data=test$outputDataframe,aes(x=fittedP3,y=devResP3)) + geom_point()
#' # a summary of the detected outlier
#' print(test$smallOutlier)
#' print(test$bigOutlier)
#' }
#' @export
FuncDetectOutlierPlantMaize <- function(datain,
                                        dateBeforeTrt,
                                        param1,
                                        param2,
                                        param3,
                                        paramGeno,
                                        paramCol, # paramLine
                                        paramRow, # paramPosition
                                        threshold,
                                        nCol, # nLine
                                        nRow, # nPosition
                                        genotype.as.random = FALSE,
                                        timeColumn) {
  
  #--- Sort before trt and add useful columns or variables
  tp <- filter(datain, get(timeColumn) == dateBeforeTrt)
  tp$R <- as.factor(tp[,paramCol])
  tp$C <- as.factor(tp[,paramRow])
  nsegL <- round(nCol/2)
  nsegC <- round(nRow/2)
  # I need to have these column names in the model
  colnames(tp)[which(colnames(tp)==paramCol)] <- "Line"
  colnames(tp)[which(colnames(tp)==paramRow)] <- "Position"
  
  #--- model SpATS
  m1 <- SpATS(response = param1, 
              spatial = ~ PSANOVA(Line, Position, nseg = c(nsegL,nsegC)),
              genotype = paramGeno, 
              random = ~ C + R, 
              genotype.as.random = genotype.as.random,
              data = tp, 
              control =  list(tolerance = 1e-03, monitoring = 0))
  
  m2 <- SpATS(response = param2, 
              spatial = ~ PSANOVA(Line,Position, nseg = c(nsegL,nsegC)),
              genotype = paramGeno, 
              random = ~ C + R, 
              genotype.as.random = genotype.as.random,
              data = tp, 
              control =  list(tolerance = 1e-03, monitoring = 0))
  
  m3 <- SpATS(response = param3, 
              spatial = ~ PSANOVA(Line,Position, nseg = c(nsegL,nsegC)),
              genotype = paramGeno, 
              random = ~ C + R, 
              genotype.as.random = genotype.as.random,
              data = tp, 
              control =  list(tolerance = 1e-03, monitoring = 0))
  
  #--- Retrieve fitted values and deviance residuals for each model
  # P1: param1
  # P2: param2
  # P3: param3
  devResP1 <- m1$residuals
  fittedP1 <- m1$fitted
  devResP2 <- m2$residuals
  fittedP2 <- m2$fitted
  devResP3 <- m3$residuals
  fittedP3 <- m3$fitted
  
  tpresu <- cbind.data.frame(tp,
                             devResP1,
                             devResP2,
                             devResP3,
                             fittedP1,
                             fittedP2,
                             fittedP3)
  
  #--- Calculate criteria for outliers
  tpresu <- mutate(tpresu,
                   mean.devP1 = mean(devResP1, na.rm=TRUE),
                   sd.devP1 = sd(devResP1, na.rm=TRUE),
                   mean.devP2 = mean(devResP2, na.rm = TRUE),           
                   sd.devP2 = sd(devResP2, na.rm = TRUE), 
                   mean.devP3 = mean(devResP3, na.rm = TRUE),         
                   sd.devP3 = sd(devResP3, na.rm = TRUE), 
                   
                   lower.devP1 = mean.devP1 - sd.devP1*qnorm(threshold), 
                   lower.devP2 = mean.devP2 - sd.devP2*qnorm(threshold), 
                   lower.devP3 = mean.devP3 - sd.devP3*qnorm(threshold), 
                   upper.devP1 = mean.devP1 + sd.devP1*qnorm(threshold), 
                   upper.devP2 = mean.devP2 + sd.devP2*qnorm(threshold), 
                   upper.devP3 = mean.devP3 + sd.devP3*qnorm(threshold), 
                   
                   lower.spatsP1 = ifelse(devResP1-lower.devP1 > 0, yes = 1, no = 0), 
                   lower.spatsP2 = ifelse(devResP2-lower.devP2 > 0, yes = 1, no = 0), 
                   lower.spatsP3 = ifelse(devResP3-lower.devP3 > 0, yes = 1, no = 0), 
                   upper.spatsP1 = ifelse(devResP1-upper.devP1 < 0, yes = 1, no = 0), 
                   upper.spatsP2 = ifelse(devResP2-upper.devP2 < 0, yes = 1, no = 0), 
                   upper.spatsP3 = ifelse(devResP3-upper.devP3 < 0, yes = 1, no = 0)
  )
  
  # small plants
  tpresu <- mutate(tpresu,
                   flagLowerSpats = ifelse(lower.spatsP1 + lower.spatsP3 == 0, 
                                           yes = 0,
                                           no = 1)
  )
  
  # big plants
  tpresu <- mutate(tpresu,
                   flagUpperSpats = ifelse(upper.spatsP1 + upper.spatsP2==0,
                                           yes = 0,
                                           no = 1)
  )
  
  #--- Detect outliers
  outlier1 <- tpresu %>% filter(flagLowerSpats == 0)
  outlier2 <- tpresu %>% filter(flagUpperSpats == 0)
  
  # return a list
  outlist <- list(tpresu, outlier1, outlier2, m1, m2, m3)
  names(outlist) <- c("outputDataframe", "smallOutlier", "bigOutlier", "m1", "m2", "m3")
  return(outlist)
}
