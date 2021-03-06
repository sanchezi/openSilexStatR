% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pointCleaning.R
\name{FuncDetectPointOutlierLocFit}
\alias{FuncDetectPointOutlierLocFit}
\title{FuncDetectPointOutlierLocFit}
\usage{
FuncDetectPointOutlierLocFit(datain, myparam, mytime, myid, mylevel, mylocfit)
}
\arguments{
\item{datain}{input dataframe. This dataframe contains a set of time courses}

\item{myparam}{character, name of the variable to model in datain 
(for example, Biomass, PH or LA and so on)}

\item{mytime}{character, name of the time variable in datain which must be numeric}

\item{myid}{character, name of the id variable in datain}

\item{mylevel}{numeric, factor to calculate the confidence interval}

\item{mylocfit}{numeric, The constant component of the smoothing parameter. (see the locfit())}
}
\value{
a data.frame with outlier containing the following columns:
\describe{
 \item{Ref}{the id variable}
 \item{mytime}{name of the time variable in datain}
 \item{myparam}{name of the modeled variable in datain}
 \item{ypred}{the locfit prediction}
 \item{sd_ypred}{standard deviation of the prediction}
 \item{lwr}{lower bound of the confidence interval}
 \item{upr}{upper bound of the confidence interval}
 \item{outlier}{flag of detected outlier (0 is outlier, 1 is not)}
}
}
\description{
function to model each curve of a dataset using a local regression
}
\details{
see locfit() help function from the locfit R library
The user can act on:
\describe{
 \item{mylocfit}{the constant of the smoothing parameter. Increase mylocfit to have a 
   very smooth curve}
 \item{mylevel}{the level to calculate the confidence interval. Increase mylevel to 
   exclude less outliers}
}

to produce the grahics of the prediction and detected outliers, please use
        plotDetectPointOutlierLocFit() function.
}
\examples{
\donttest{
data(plant1)
library(locfit)
selec<-c("manip1_1_1_WW","manip1_1_2_WW","manip1_1_3_WW",
         "manip1_1_4_WW","manip1_1_5_WW")
mydata<-plant1[plant1[,"Ref"] \%in\% selec,]
resu<-FuncDetectPointOutlierLocFit(datain=mydata,
               myparam="biovolume",mytime="thermalTime",
               myid="Ref",mylevel=5,mylocfit=70)
}
}
