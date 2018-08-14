#making data set for text analysis

new_dir<-list.dirs("data/bbc",full.names = F)

################################################################
# variable containing complete label data
BBC<-list()
x<-1
for(i in new_dir){
  news_dir<-paste0("data/bbc/",i)
  ls_files<-list.files(news_dir,full.names = T)
  dat<-list()
  k<-1
  for(j in ls_files){
    txt<-readLines(j)
    txt<-paste(txt, sep = "", collapse = "")
    txt<-clean_text(txt)
    dat[[k]]<-c(txt,i)
    k<-k+1; print(paste("reading file ",j,"in ",i))
  }
  dat<-plyr::ldply(dat)
  BBC[[x]]<-dat
  x<-x+1
}

BBC<-plyr::ldply(BBC)
###############################################################################
###############################################################################

colnames(BBC)<-c("Text","Category")
BBC$Category<-factor(BBC$Category,levels=new_dir)

# Data preparation
set.seed(777)
# divide data set into training and test sets
tr_prop = 0.8    # proportion of full dataset to use for training
bbc_train = plyr::ddply(BBC, .(Category), function(., seed) { set.seed(seed); .[sample(1:nrow(.), trunc(nrow(.) * tr_prop)), ] }, seed = 101)
bbc_test = ddply(BBC, .(Category), function(., seed) { set.seed(seed); .[-sample(1:nrow(.), trunc(nrow(.) * tr_prop)), ] }, seed = 101)

# check that proportions are equal across datasets
ddply(BBC, .(Category), function(.) nrow(.)/nrow(BBC) )
ddply(bbc_train, .(Category), function(.) nrow(.)/nrow(bbc_train) )
ddply(bbc_test, .(Category), function(.) nrow(.)/nrow(bbc_test) )
#Proporstion
data.frame("Training Set"=nrow(training_set),"Test Set"= nrow(test_set),"BBC"= nrow(BBC)) # lengths of se

save(list(BBC,bbc_train,bbc_test),"processed.RData")
rm(ls())