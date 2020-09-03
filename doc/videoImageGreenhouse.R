## ----libraries,echo=FALSE,message=FALSE, warning=FALSE,error=TRUE-------------
  #-- Loading of librairies
  library(tidyr)
  library(dplyr)
  library(openSilexStatR)
  library(animation)

## ----echo=TRUE,message=FALSE, warning=FALSE-----------------------------------
  # import a temporal dataframe from phisStatR package:
  data(plant1)

  str(plant1)
  
  head(plant1)
  
  # Number of Days in the dataframe (in the experiment)
  table(plant1[,"Day"])

  plant1<-arrange(plant1,Day)
    

## ---- echo=TRUE,eval=FALSE,message=FALSE, warning=FALSE-----------------------
#      #----------------------------------------------------
#      #heat map biovolume per Day and creation of a gif video
#      #----------------------------------------------------
#      vecDay<-na.omit(unique(plant1[,"Day"]))
#  
#      videoFileName<-"biovolume"
#  
#      saveVideo({
#        for (tmpday in 1:length(vecDay)){
#          imageGreenhouse(datain=filter(plant1,Day==vecDay[tmpday]),trait="biovolume",typeD=1,typeT=1,ylim=NULL,
#                          xcol="Line",ycol="Position",numrow=28,numcol=60,
#                          typeI="video")
#        }
#        ani.options(interval = 1,ani.dev="png",ani.height=480)
#        },
#        video.name = paste0(thepath,"/output/",videoFileName,".gif"),
#        other.opts = paste0("-y -r ",length(vecDay)+2," -i Rplot%d.png -dframes ",
#                            length(vecDay)+2," -r ",length(vecDay)+2)
#      )
#  
#    # Call the video in a Rmarkdown file
#    #![](/my-path-to-project/output/humidity.gif)
#  

## ----session,echo=FALSE,message=FALSE, warning=FALSE--------------------------
  sessionInfo()

