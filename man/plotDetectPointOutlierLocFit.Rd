% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/graphicalFunctions.R
\name{plotDetectPointOutlierLocFit}
\alias{plotDetectPointOutlierLocFit}
\title{plotDetectPointOutlierLocFit}
\usage{
plotDetectPointOutlierLocFit(datain, resuin, myparam, mytime, myid)
}
\arguments{
\item{datain}{input dataframe. This dataframe contains a set of time courses}

\item{resuin}{input dataframe of results from funcDetectPointOutlierLocFit function.}

\item{myparam}{character, name of the variable to model in datain 
(for example, Biomass, PH or LA and so on)}

\item{mytime}{character, name of the time variable in datain which must be numeric}

\item{myid}{character, name of the id variable in datain}
}
\value{
graphics
}
\description{
graphical function to produced the modelled smoothing and detected outliers 
   for each curve of a dataset using a local regression
--- Input:
}
\details{
see locfit() help function from the locfit R library

see funcDetectPointOutlierLocFit function
}
\examples{
library(locfit)
selec<-c("manip1_1_1_WW","manip1_1_2_WW","manip1_1_3_WW")
mydata<-plant1[plant1[,"Ref"] \%in\% selec,]
resu<-FuncDetectPointOutlierLocFit(datain=mydata,
               myparam="biovolume",mytime="thermalTime",
               myid="Ref",mylevel=5,mylocfit=70)
plotDetectPointOutlierLocFit(datain=mydata,resuin=resu,myparam="biovolume",
                            mytime="thermalTime",myid="Ref")
}
