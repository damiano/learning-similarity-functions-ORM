#Remove unrelated tweets from system outputs
setwd(PATH_OF_YOUR_LOCAL_COPY) #Set to main dir in your local copy. Example: /home/damiano/data/learning-similarity-functions

old.dir <- "./data/results"
new.dir <- "./data/system-outputs"
systems <- list.files(old.dir,full.names=T,include.dirs=F)

goldstandard <- read.table(file="./data/goldstandard/goldstandard_topic_detection.dat",header=T,sep='\t',comment.char="",quote="\"",colClasses="character")

for(system.filename in systems) {
  print(sprintf("Reading %s",system.filename))
  system <- read.table(file=system.filename,header=T,sep='\t',comment.char="",quote="\"",colClasses="character")
  names(system) <- names(goldstandard)
  intersection <- intersect(system$tweet_id,goldstandard$tweet_id)
  system.normalized <- system[system$tweet_id %in% intersection,]
  system.normalized <- system.normalized[!duplicated(system.normalized$tweet_id), ]
  system.normalized.filename <- sub(old.dir,new.dir,system.filename)
  write.table(system.normalized, file=system.normalized.filename,  sep="\t",row.names=FALSE, col.names=TRUE, quote=T,qmethod="double")
}
