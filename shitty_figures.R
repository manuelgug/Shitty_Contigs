#if not installed, install ggplot2 
if(!is.element(c("ggplot2"), installed.packages()[,1])){
    install.packages(c("ggplot2"), dep = TRUE)
}

library(ggplot2)

#lista all .table files, both their contents and their names
dataFiles <- lapply(Sys.glob("*.table"), read.csv, header = F, na.strings=c(1:10), sep="")
myFiles <- list.files(pattern="*table$")

#generate figures
for (i in 1:length(dataFiles)){
  png(paste(myFiles[i],".png", sep=""), res = 200, width = 14, height = 10, units = "cm")
  print(ggplot(na.omit(as.data.frame(dataFiles[i])), aes(x=reorder(V2, V1),y=V1), fill = V2) + 
    geom_bar(stat = "identity", fill = c(rep("orange", length(na.omit(as.data.frame(dataFiles[i]))$V2)-1), "green4"))+
    coord_flip()+
    xlab("Genera with >10 hits") + 
    ylab("Blast hits"))
  dev.off()
}
