#------------------------------------------------------------------
# Program: graphicalFunctions.R
# Objective: graphical functions for phenoarch experiment data analysis
# Author: I.Sanchez
# Creation: 27/07/2016
# Update: 04/09/2020
#------------------------------------------------------------------

#' @title a function for representing a trait in the phenoarch greenhouse
#' @description a function for representing a trait in the phenoarch greenhouse
#' @details the data.frame in input must have the positions of each pot (Line and
#' Position columns).
#'
#' For plotly type graphic, the data frame in input must also contain id of plants
#' (Manip, Pot, Genotype, Repsce)
#' @param datain a dataframe to explore
#' @param trait character, a parameter to draw
#' @param xcol character, name of the abscissa column ("Line" or "x"...)
#' @param ycol character, name of the ordinate column ("Position" or "y"...)
#' @param numrow numeric, number of rows in the greenhouse
#' @param numcol numeric, number of columns in the greenhouse
#' @param daycol character, name of the day time column ("Day" or "Time"...) 
#'               necessary for video call.
#' @param typeD numeric, type of dataframe (1==wide, 2==long). If typeD==2, the input dataset must contain
#'              a 'Trait' column. 
#' @param typeT numeric, type of the trait (1: quantitatif, 2: qualitatif), 1 is the default
#' @param ylim if trait is quantitative, numeric vectors of length 2, giving the trait coordinates ranges.
#'        default = NULL
#' @param typeI character, type of image.
#'          "video" for createDynam.R program that produces a video of an experiment,
#'          "plotly" for interactive graphic for spatial visualisation,
#'          "ggplot2" for classical graphic in report pdf , default.
#' @param typeV character, type de video, NULL by default, "absolute" for abs. video
#' @importFrom ggplot2 ggplot aes labs theme element_text scale_y_discrete scale_colour_brewer scale_fill_gradient2 scale_colour_gradient
#' @importFrom dplyr filter group_by mutate select
#'
#' @return a ggplot2 object if plotly, the print of the ggplot2 object (a graph) otherwise
#'
#' @examples
#' \donttest{
#' library(dplyr)
#' # a video call
#' library(dplyr)
#' selec<-"2017-04-14"
#' # in PAdata, daycol=="Time"
#' imageGreenhouse(datain=filter(PAdata,Time==selec),trait="Height_Estimated",
#'                  xcol="Row",ycol="Col",numrow=28,numcol=60,daycol="Time",
#'                  typeD=1,typeT=1,ylim=NULL,typeI="video")
#' # an interactive plotly call
#' test<-imageGreenhouse(datain=plant4, trait="Biomass24",xcol="Line",ycol="Position",
#'                  numrow=28,numcol=60,
#'                  typeD=1,typeT=1, ylim=NULL,typeI="plotly")
#' # test is a ggplot2 object, you have to render it with: plotly::ggplotly(test)
#' # a classical ggplot2 call
#' imageGreenhouse(datain=plant4, trait="Biomass24",xcol="Line",ycol="Position",
#'                 numrow=28,numcol=60,typeD=1,typeT=1, ylim=NULL,typeI="ggplot2")
#' }
#' @export
imageGreenhouse<-function(datain,trait,xcol,ycol,
                          numrow,numcol,daycol=NULL,
                          typeD,typeT=1,
                          ylim=NULL,
                          typeI="ggplot2",typeV=NULL){

  datain<-as.data.frame(datain)

  #------------------------------------------
  # renames columns if necessary:
  #------------------------------------------
  tmpname<-names(datain)
  tmpname[tmpname==xcol]<-"Line"
  tmpname[tmpname==ycol]<-"Position"
  tmpname[grep("^geno",tmpname,perl=TRUE)]<-"Genotype"
  tmpname[grep("^Geno",tmpname,perl=TRUE)]<-"Genotype"
  tmpname[grep("^pot",tmpname,perl=TRUE)]<-"Pot"
  tmpname[grep("^Pot",tmpname,perl=TRUE)]<-"Pot"
  tmpname[grep("^reps",tmpname,perl=TRUE)]<-"Repsce"
  tmpname[grep("^Reps",tmpname,perl=TRUE)]<-"Repsce"
  names(datain)<-tmpname

  #------------------------------------------
  
  if (typeD==1){ #wide format column==differents traits
    tmp.sp<-datain
  } else if (typeD==2){ # long format 1 column Trait, 1 column value
    tmp.sp<-datain[datain[,"Trait"]==trait,]
  }
  
  # get the day for video generation
  if (typeI=="video") dayin<-unique(datain[,daycol])

  # Take care that position must be reordered from 1-60 to 60-1 for the graphic
  # ordering the dataset
  tmp.sp<-tmp.sp[order(tmp.sp[,"Position"],tmp.sp[,"Line"]),]
  # Rebuild of the greenhouse, taking into account the missing data (important)!
  mymat<-matrix(nrow=numrow,ncol=numcol)
  for (i in seq(1:nrow(mymat))){
    for (j in seq(1:ncol(mymat))){
      if (isTRUE(rownames(tmp.sp)[tmp.sp["Line"]==i & tmp.sp["Position"]==j][1] > 0))
        mymat[i,j]<-tmp.sp[rownames(tmp.sp)[tmp.sp["Line"]==i & 
                                            tmp.sp["Position"]==j][1],trait]
      else mymat[i,j]<-NA
    }
  }

  melted.tmp <- reshape2::melt(mymat,varnames=c("Line","Position"))

  # specific title for video type
  #-------
  if (typeI=="video") {
    if (is.null(typeV)){
      if (trait=="height") titlein<-paste("Growth Rate phenoarch greenhouse -",dayin,sep=" ")
      else titlein<-paste(trait,"phenoarch greenhouse -",dayin,sep=" ")
    } else {
      titlein<-paste(trait,"phenoarch greenhouse -",dayin,sep=" ")
    }
  } else {
    titlein<-paste(trait,"phenoarch greenhouse",sep=" ")
  }

  # for interactive plot, the ids of each plant appears with mouse scroll
  #-------
  if (typeI=="plotly"){
    # if the column 'Manip' exists...
    if (sum(tmpname =="Manip") == 1) {
      melted.tmp<-merge(melted.tmp,select(tmp.sp,Line,Position,Manip,Pot,Genotype,Repsce),
                        by.x=c("Position","Line"),by.y=c("Position","Line"),all.x=TRUE,all.y=FALSE)
      melted.tmp[,"Ident"]<-paste0("Manip:",melted.tmp[,"Manip"],"<br>",
                                   "Pot:",melted.tmp[,"Pot"],"<br>",
                                   "Genotype:",melted.tmp[,"Genotype"],"<br>",
                                   "Rep sce:",melted.tmp[,"Repsce"]
                                    )
    } else {
      melted.tmp<-merge(melted.tmp,select(tmp.sp,Line,Position,Pot,Genotype,Repsce),
                        by.x=c("Position","Line"),by.y=c("Position","Line"),all.x=TRUE,all.y=FALSE)
      melted.tmp[,"Ident"]<-paste0("Pot:",melted.tmp[,"Pot"],"<br>",
                                   "Genotype:",melted.tmp[,"Genotype"],"<br>",
                                   "Rep sce:",melted.tmp[,"Repsce"]
                                    )
    }
  }

  melted.tmp[,"Line"]<-as.factor(melted.tmp[,"Line"])
  melted.tmp[,"Position"]<-factor(melted.tmp[,"Position"],
                                  levels = rev(sort(unique(melted.tmp[,"Position"]))))

  ### if quantitative variable
  ###---------------------------
  if (typeT==1){
    if (typeI=="plotly"){
      g<-ggplot(data = melted.tmp, aes(x=Line, y=Position, fill=value,label=Ident))
    } else {
      g<-ggplot(data = melted.tmp, aes(x=Line, y=Position, fill=value))
    }
    g<-g + ggplot2::geom_tile() +
        labs(x="Line",y="Position",title=titlein) +
        theme(plot.title = element_text(size=18)) +
        scale_y_discrete(labels=seq(numcol,1,-1)) +
        if (is.null(ylim)){
            scale_fill_gradient2(low = "blue",high="red",mid="white",
                        midpoint=round(mean(tmp.sp[,trait],na.rm=TRUE),2),na.value="black")
        } else {
          #if (is.null(typeV)){
            scale_fill_gradient2(low = "blue",high="red",mid="white",limits=c(ylim[1],ylim[2]),
                                          midpoint=mean(ylim),na.value="black")
          #} #else if (typeV=="absolute"){
            #scale_colour_gradient(low = "#98FB98", high = "#556B2F",limits=c(ylim[1],ylim[2]),
            #                               na.value = "black")
          #}
        }
  ### if qualitative variable
  ###---------------------------
  } else if (typeT==2){
    if (typeI=="plotly"){
      g<-ggplot(data = melted.tmp, aes(x=Line, y=Position, fill=as.factor(value),label=Ident))
    } else {
      g<-ggplot(data = melted.tmp, aes(x=Line, y=Position, fill=as.factor(value)))
    }
    g<-g + ggplot2::geom_tile() +
       labs(x="Line",y="Position",title=titlein) +
       theme(plot.title = element_text(size=18)) + scale_y_discrete(labels=seq(numcol,1,-1)) +
       scale_colour_brewer(name=trait,palette = "Set1",na.value="black")
  }
  # if interactive plot, the return must be a ggplot2 object (and not the print of the ggplot2 object...)
  #---------------------------
  if (typeI=="plotly"){
    return(g)
  } else {
    return(print(g))
  }
}



##' @title a function for representing a smoothing spline anova result
##' @description produce a graphic of Smoothing splines anova fitting
##' @details the dataframe in input must contain Genosce, repetition and thermalTime columns!
##' @param datain a dataframe
##' @param modelin a list of output of ssanova()
##' @param trait a variable to explore
##' @param myvec a numeric vector for facet graph
##' @param lgrid length of the regular grid for ssanova prediction
##' @return a ggplot2 graph object
##' 
##' @importFrom ggplot2 ggplot geom_line geom_ribbon geom_point facet_wrap
##'
##' @examples
##' # Not run
##'
##' @export
plotGSS<-function(datain,modelin,trait,myvec,lgrid){
  tmp1<-as.data.frame(datain)
  ## selection of data + retrieve min and max by Genosce-repetition
  select<-unique(tmp1[,"Genosce"])
  tmp1<-na.omit(dplyr::filter(tmp1,Genosce %in% select[myvec]))
  tmp2<-as.data.frame(dplyr::summarise(dplyr::group_by(tmp1,Genosce,repetition),
                                       mymin=min(thermalTime,na.rm=TRUE),
                                       mymax=max(thermalTime,na.rm=TRUE)))
  ## creation grid
  tp<-numeric()
  Genosce<-character()
  repetition<-numeric()
  for (j in 1:nrow(tmp2)){
    tp<-c(tp,seq(tmp2[j,3],tmp2[j,4],length=lgrid))
    Genosce<-c(Genosce,rep(tmp2[j,1],lgrid))
    repetition<-c(repetition,rep(tmp2[j,2],lgrid))
  }
  ngrid<-cbind.data.frame(Genosce,thermalTime=tp,repetition)
  ngrid[,"Genosce"]<-factor(ngrid[,"Genosce"])
  ## prediction on new grid
  fm.fit<-numeric()
  fm.se<-numeric()
  k<-1
  mygeno<-unique(as.character(ngrid[,"Genosce"]))
  for (j in myvec){
    fm.fit<-c(fm.fit,predict(modelin[[j]],newdata=ngrid[ngrid[,"Genosce"] == mygeno[k],],se=TRUE)$fit)
    fm.se<-c(fm.se,predict(modelin[[j]],newdata=ngrid[ngrid[,"Genosce"] == mygeno[k],],se=TRUE)$se.fit)
    k<-k+1
  }
  ngrid<-cbind.data.frame(ngrid,fm.fit,fm.se)
  ngrid[,"Genosce"]<-factor(ngrid[,"Genosce"])
  ngrid[,"repetition"]<-factor(ngrid[,"repetition"])
  tmp1[,"Genosce"]<-factor(tmp1[,"Genosce"])
  tmp1[,"repetition"]<-factor(tmp1[,"repetition"])

  ## plot
  g <- ggplot(ngrid,ggplot2::aes(x = thermalTime,colour = repetition,group = repetition)) +
          geom_line(ggplot2::aes(y = fm.fit),alpha = 1,colour = "grey20") +
          geom_ribbon(ggplot2::aes(ymin = fm.fit-(1.96*fm.se), 
                                   ymax = fm.fit+(1.96*fm.se),
                                   fill = repetition),
                           alpha = 0.5,colour = "NA") +
          geom_point(data=tmp1,ggplot2::aes_string(x = "thermalTime",y=trait,colour = "repetition")) +
          facet_wrap(~ Genosce,ncol=3)
  return(g)
}


##' @title a function for representing distribution using histogram and flag
##' @description produce a graphic of the ditribution of a trait with the detected
##' outlier points according to a specified flag method
##' @param datain a dataframe
##' @param trait a variable to explore
##' @param flag a method of flag for outlier detection (column name in datain)
##' @param labelX a label for abscissa
##' @return a graph
##' @importFrom graphics abline hist lines par plot points text
##' @importFrom dplyr filter select
##' @importFrom ggplot2 aes geom_histogram geom_point ggplot xlab
##'
##' @examples
##' library(dplyr)
##' data(plant4)
##' mydata<-mutate(plant4,flag=if_else(Phy <= 0.215,0,1))
##' outlierHist(datain=mydata,trait="Phy",
##'               flag="flag",labelX="Phyllocron")
##' @export
outlierHist<-function(datain,trait,flag,labelX){
  # formatting
  datain<-as.data.frame(datain)
  selec<-filter(datain,.data[[flag]] == 0)
  
  # graph
  ggplot(mydata,aes_string(x=trait)) + 
      geom_histogram() + 
      geom_point(data=selec,aes_string(x=trait,y=0),color="red") +
      xlab(label=labelX)
}


#' a function for representing a CARBayesST result
#'
#' @param datain the input dataframe used in \code{\link[=fitCARBayesST]{fitCARBayesST}} to detect outlier points in time courses
#' @param outlierin the input dataframe identifying the outlier points in the time courses, output of the \code{\link[=outlierCARBayesST]{outlierCARBayesST}}
#' @param myselect a numeric vector for facet graph
#' @param trait a variable to explore
#' @param xvar character, time variable (ex: thermalTime)
#' @details the input dataset must contain scenario,genotypeAlias and Repsce (combination of repetition and scenario) columns
#' @importFrom ggplot2 geom_point geom_line facet_wrap aes_string
#' @importFrom dplyr filter
#'
#' @return a ggplot2 graph object
#' @export
#'
#' @examples
#' # not run
plotCARBayesST<-function(datain,outlierin,myselect,trait,xvar){
  # filtering datain dataframe for some genotype
  tmp<-filter(datain,genotypeAlias %in% mygeno[myselect])
  # on those genotypes, filtering outlierin to identify the outlier points
  toto<-filter(outlierin,crit==0 & genotypeAlias %in% mygeno[myselect])
  selectVariete<-unique(toto$genotypeAlias)
  # identifying the outlier points in tmp
  tutu<-filter(tmp,genotypeAlias %in% selectVariete)

  g<-ggplot(data = tutu, aes_string(x = xvar, y = trait,color="scenario")) + 
    geom_point() +
    geom_line(aes(color=scenario,linetype=Repsce))  +
    geom_point(data=toto,aes_string(x = xvar, y = trait),colour="black") +
    facet_wrap(~ genotypeAlias) + labs(title=trait)
  print(g)
}


#-------------------------------------------------------------------
#' plotDetectPointOutlierLocFit
#' @description graphical function to produced the modelled smoothing and detected outliers 
#'    for each curve of a dataset using a local regression
#' --- Input:
#' @param datain input dataframe. This dataframe contains a set of time courses
#' @param resuin input dataframe of results from funcDetectPointOutlierLocFit function.
#' @param myparam character, name of the variable to model in datain 
#'                 (for example, Biomass, PH or LA and so on)
#' @param mytime character, name of the time variable in datain which must be numeric
#' @param myid character, name of the id variable in datain
#' 
#' @details see locfit() help function from the locfit R library
#' @details see funcDetectPointOutlierLocFit function
#'
#' @return graphics 
#' @examples
#' library(locfit)
#' selec<-c("manip1_1_1_WW","manip1_1_2_WW","manip1_1_3_WW")
#' mydata<-plant1[plant1[,"Ref"] %in% selec,]
#' resu<-FuncDetectPointOutlierLocFit(datain=mydata,
#'                myparam="biovolume",mytime="thermalTime",
#'                myid="Ref",mylevel=5,mylocfit=70)
#' plotDetectPointOutlierLocFit(datain=mydata,resuin=resu,myparam="biovolume",
#'                             mytime="thermalTime",myid="Ref")
#' @export
plotDetectPointOutlierLocFit <-function(datain,
                                        resuin,
                                        myparam,
                                        mytime,
                                        myid) {
  selectOutlier<- resuin %>% dplyr::filter(outlier == 1)
  
  p<-ggplot(datain,aes_string(x=mytime,y=myparam)) + 
    ggplot2::geom_point()  +
    ggplot2::facet_wrap(facets=myid) +
    ggplot2::geom_line(data = resuin,col = "green",size = .8,
                       mapping = ggplot2::aes_string(x = mytime, y = "lwr")) +
    ggplot2::geom_line(data = resuin,col = "green",size = .8,
                       mapping = ggplot2::aes_string(x = mytime, y = "upr")) +
    ggplot2::geom_line(data = resuin,col = "red",size = .8,
                       mapping = ggplot2::aes_string(x = mytime, y = "ypred")) +
    ggplot2::geom_point(data = selectOutlier,
                        mapping = ggplot2::aes_string(x = mytime, y = myparam),
                        col = "blue",size = 2) +
    ggplot2::theme(legend.position = "none")
  return(p)
}



#' plotDetectOutlierPlantMaize
#' @description function producing a graphic of detected outlier plants from 
#'              funcDetectOutlierPlantMaize() function
#'              
#' @param datain input dataframe, a spatio-temporal data.frame
#' @param outmodels the output object from funcDetectOutlierPlantMaize() function
#'                   containing the detected outliers (either small or big)
#'                   'theobject$smallOutliers' or 'theobject$bigOutliers'
#' @param x character, name of the time variable in datain
#' @param y character, name of the variable in datain to draw
#' @param genotype character, name of the genotype variable in datain
#' @param idColor character, name of the treatment variable in datain to differentiate
#'                  the curves
#' @param idFill character, name of the repetition variable in the datain to differentiate
#'                  the outlier curves
#' 
#' @details see funcDetectOutlierPlantMaize function
#' 
#' @return a graphic
#' @examples
#' \donttest{
#' #plotDetectOutlierPlantMaize(datain=PAdata,
#' #          outmodels=test$smallOutlier,
#' #          x="Time",
#' #         y="Biomass_Estimated",
#' #          genotype="Genotype",
#' #          idColor="Treatment",
#' #         idFill="plantId")
#' }
#' @export
plotDetectOutlierPlantMaize <- function(datain,
                                        outmodels,
                                        x,
                                        y,
                                        genotype,
                                        idColor,
                                        idFill) {
  # some datamanagement  
  selectGeno<-as.character(unique(outmodels[,genotype]))
  tmp<- datain %>% dplyr::filter(.[[genotype]] %in% selectGeno)
  tmpout<- datain %>% dplyr::filter(.[[idFill]] %in% outmodels[,idFill])
  
  ggplot(data = tmp, ggplot2::aes_string(x = x, y = y, color = idColor, fill = idFill)) + 
    ggplot2::geom_point(size = .8) + 
    ggplot2::facet_wrap(facets=genotype) +
    # detected plants
    ggplot2::geom_point(data = tmpout,
                        mapping = ggplot2::aes_string(x = x, y = y, 
                                                      group = genotype, 
                                                      fill = idFill),
                        col = "black",size = .8) +
    ggplot2::theme(legend.position = "none")
}

#----------- End of file ---------------------------
