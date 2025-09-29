setwd("~/articolo_elena/analisi/")

setwd("program/gone_55")
getwd()


sw=theme_minimal()+theme(#axis.line = element_line(),
  strip.text.y = element_text(size = 25,face ="italic",angle=.9),
  strip.text.x = element_text(size = 25,face ="italic",angle=.9),
  panel.grid.major = element_blank(),
 # plot.background = element_rect(fill = "white"),
 # panel.grid.minor = element_blank(),
     plot.title = element_text( face="bold",  size=20),
     plot.subtitle = element_text( face="italic",  size=16,element_text(hjust = 0.5)),
   axis.title.y = element_text(face = "italic",size=25),
  axis.title.x = element_text(face = "italic",size=20),
 axis.line.x = element_line(size = .5, colour = "black"),
 axis.text.y = element_text(size = 20, face = "italic"),
   axis.text.x = element_text(size = 20, face = "italic"),
   #strip.text.x = element_text(size=24, face="bold"),
   legend.text = element_text(size = 20, face = "italic"),
   legend.title=element_text(size=20),
  panel.background = element_blank(),
 # axis.text.x = element_blank(), axis.ticks.x = element_blank(),
  #axis.text.y = element_blank(), axis.ticks.y = element_blank(),
  #legend.position="none",
   panel.border = element_rect(colour = "grey10", fill=NA, size=1)
   )

db=system("ls *Ne*",intern=TRUE)
#db=db[-length(db)]

fx=function(i){
        cat(i,"\n")
        nome=gsub("Output_Ne_","",db[i])
        nome=gsub("_cln","",nome)
        dbx=data.frame(data.table::fread(db[i]))
        dbx$Breed=nome
        return(dbx)
}

require("tidyverse")
GENAGO=50

gone=do.call("rbind",lapply(1:4,fx))
#png("ok.png")
ggplot(gone %>% filter(Generation<GENAGO),aes(x=Generation,y=(Geometric_mean),color=Breed))+
geom_line(size=1)+sw
dev.off()

# 
setwd("~/articolo_elena/analisi/data_modfiy")
setwd("SNep")

db=system("ls *NeAll",intern=TRUE)

fx=function(i){
        cat(i,"\n")
        nome=gsub(".NeAll","",db[i])
        nome=gsub("_cln","",nome)
        dbx=data.frame(data.table::fread(db[i]))
        dbx$Breed=nome
        return(dbx)
}

getwd()

snep=do.call("rbind",lapply(1:4,fx))
head(gone)
head(snep)
names(snep)[1]="Generation"
names(gone)[2]="Ne"
snep$method="SNep"
gone$method="GONE"

all=rbind(snep[,c("Generation","Ne","Breed","method")],gone[,c("Generation","Ne","Breed","method")])

require(ggplot2)
require(tidyverse)

all[all$Breed=="Alpagota","Breed"]="LPG"
all[all$Breed=="Brogna","Breed"]="BRN"
all[all$Breed=="Foza","Breed"]="FOZ"
all[all$Breed=="Lamon","Breed"]="LMN"


A=ggplot(all%>%filter(Generation %in% 1:GENAGO),aes(x=Generation,y=Ne,color=Breed,fill=Breed))+
geom_line()+facet_grid(method~.,scale="free")+sw

getwd()
png("../gooddb/plot/Ne.png", res = 300, width = 10, height = 7, units = "in")
A
dev.off()
system("ls ../")