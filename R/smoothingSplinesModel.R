#-------------------------------------------------------------------------------
# Program: smmothingSplinesModel.R
# Objective: modelling of curves according to smoothing splines
#            require gss package
# Author: I.Sanchez
# Creation: 28/07/2016
# Update: 04/09/2020
#-------------------------------------------------------------------------------

##' a function to model curves using smoothing splines anova using \code{gss} library
##' @description this function models each curve of genotype using smoothing
##' splines anova
##' @param datain input dataframe
##' @param trait character, trait of interest to model (example biovolume, PH ...)
##' @param loopId a column name that contains ident of Genotype-Scenario
##' @details the input dataframe must contain the following columns: the trait to model,
##' the ident of Genotype-Scenario, thermalTime, repetition columns
##' 
##' @details Each time course is modelled by a nonparametric smoothing spline. This is a piecewise cubic polynomial
##' (Eubank, 1999). Then a functional ANOVA decomposition (Gu, 2014) of all the fitted splines for each
##' genotype by environmental treatment combination is realised, by taking into account the replicate effect and
##' a temporal functional effect. The smoothing spline fitting and the functional ANOVA decompositions are be
##' performed with the gss R package. 
##'
##' @return a list containing 2 objects
##' \describe{
##' \item{}{a list of each output of \code{\link[=ssanova]{ssanova}}}
##' \item{}{a dataframe of kullback-Leibler projection}
##' }
##'
##' @seealso \code{\link[=project.ssanova]{project.ssanova}}, \code{\link[=ssanova]{ssanova}}
##' 
##' @importFrom dplyr select
##' @examples
##' \donttest{
##' data(plant1)
##' selec<-c("Lo1199_H","Lo1124_H","Lo1038_H","A3_H")
##' mydata<-plant1[plant1[,"genotypeAlias"] %in% selec,]
##'  fm1<-fitGSS(datain=mydata,trait="biovolume",loopId="genotypeAlias")
##' }
##' @export
fitGSS<-function(datain,trait,loopId){
  # formating
  tmpdata<-as.data.frame(datain)
  tmpdata<-select(tmpdata,
                  .data[[loopId]],thermalTime,repetition,.data[[trait]])
  
  # smoothing splines model
  fm<-list()
  resu<-NULL
  genosceId<-unique(tmpdata[,loopId])
  for(i in 1:length(genosceId)){
    tmp<-na.omit(tmpdata[tmpdata[,loopId]==genosceId[i],])
    fm[[i]]<-gss::ssanova(as.formula(paste0(trait,"~repetition + thermalTime + repetition:thermalTime")),data=tmp,seed=1234)
    tpproj<-cbind.data.frame(genosceId[i],
                             t(unlist(gss::project(fm[[i]],inc=c("thermalTime","repetition")))))
    names(tpproj)[1]<-loopId
    resu<-rbind.data.frame(resu,tpproj)
  }
  result <- list(fm=fm,projKL=resu)
  return(result)
}

#' a function for gss analysis description
#' @param object a dataframe to describe from fitGSS() function
#' @param threshold numeric, a threshold for Kullback-Leibler projection
#'
#' @seealso \code{\link[=ssanova]{ssanova}}
#' @details the input object is a fitGSS result and printGSS() prints the 2nd element of it (a dataframe 
#'          with the Kullback-Leibler projection).
#'          The colnames of this dataframe are Genosce, ratio, kl, check. 
#'          The outlier curves are identified with the Kullback-Lleiber 
#'          distance higher than a given threshold, see (Gu, 2014). 
#'          Final identification of outlier is done by an operator over
#'          genotypes when the test is significant.
#' @return a description
#'
#' @examples
#' data(plant1)
#' selec<-c("Lo1199_H","Lo1124_H","Lo1038_H","A3_H")
#' mydata<-plant1[plant1[,"genotypeAlias"] %in% selec,]
#' fm1<-fitGSS(datain=mydata,trait="biovolume",loopId="genotypeAlias")
#'  printGSS(object=fm1,threshold=0.05)
#' @export
printGSS<-function(object,threshold){
  tmp<-as.data.frame(object[[2]])
  if (!(is.null(threshold)))  tmp<-filter(tmp,ratio > threshold)
  return(tmp)
}
