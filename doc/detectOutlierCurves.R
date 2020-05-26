## ----echo=TRUE,message=FALSE, warning=FALSE,error=FALSE------------------
  library(dplyr)
  library(tidyr)
  library(openSilexStatR)
  library(ggplot2)

## ----echo=TRUE,message=FALSE, warning=FALSE,error=FALSE------------------
  mydata<-PAdata
  str(mydata)

## ------------------------------------------------------------------------
test<-FuncDetectOutlierPlantMaize(datain=mydata,dateBeforeTrt="2017-04-27",
                param1="Biomass_Estimated",param2="Height_Estimated",
                param3="phyllocron",paramGeno="Genotype",
                paramCol="Col",paramRow="Row",
                threshold=0.95,nCol=28,nRow=60,genotype.as.random=FALSE,
                timeColumn = "Time")


## ----spatplot1,echo=TRUE,message=FALSE, warning=FALSE,error=FALSE--------
  plot(test$m1, spaTrend = "percentage")

## ----spatplot2,echo=TRUE,message=FALSE, warning=FALSE,error=FALSE--------
  plot(test$m2, spaTrend = "percentage")

## ----spatplot3,echo=TRUE,message=FALSE, warning=FALSE,error=FALSE--------
  plot(test$m2, spaTrend = "percentage")

## ------------------------------------------------------------------------
ggplot(data=test$outputDataframe,aes(x=fittedP1,y=devResP1)) + geom_point()


## ----echo=TRUE,message=FALSE, warning=FALSE------------------------------
test$smallOutlier
test$bigOutlier

## ------------------------------------------------------------------------
plotDetectOutlierPlantMaize(datain=PAdata,
                            outmodels=test$smallOutlier,
                            x="Time",
                            y="Biomass_Estimated",
                            genotype="Genotype",
                            idColor="Treatment",
                            idFill="plantId")

## ------------------------------------------------------------------------
plotDetectOutlierPlantMaize(datain=PAdata,
                            outmodels=test$bigOutlier,
                            x="Time",
                            y="Biomass_Estimated",
                            genotype="Genotype",
                            idColor="Treatment",
                            idFill="plantId")

## ----session,echo=FALSE,message=FALSE, warning=FALSE---------------------
  sessionInfo()

