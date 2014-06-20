#Remove unrelated tweets from system outputs
setwd(...) #Specify absolute path of this directory
systems <- list.files("../training/systems",full.names=T,include.dirs=F)


goldstandard <- read.table(file="../training/systems/goldstandard_topic_detection.dat",header=T,sep='\t',comment.char="",quote="\"",colClasses="character")
new.systems  <- read.table(file="../training/new/topics_SVM_0%",header=F,sep='\t',comment.char="",quote="\"",colClasses="character")
names(new.systems) <- names(goldstandard)

intersection <- intersect(new.systems$tweet_id,goldstandard$tweet_id)

for(system.filename in systems) {
  print(sprintf("Reading %s",system.filename))
  system <- read.table(file=system.filename,header=T,sep='\t',comment.char="",quote="\"",colClasses="character")
  names(system) <- names(goldstandard)
  system.normalized <- system[system$tweet_id %in% intersection,]
  system.normalized <- system.normalized[!duplicated(system.normalized$tweet_id), ]
  system.normalized.filename <- sub("systems","systems_normalized",system.filename)
  write.table(system.normalized, file=system.normalized.filename,  sep="\t",row.names=FALSE, col.names=TRUE, quote=T,qmethod="double")
}
