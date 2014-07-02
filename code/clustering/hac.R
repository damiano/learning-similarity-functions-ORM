require(data.table)
require("foreach")
require("doMC")
require("fastcluster")

##PARAMETERS TO BE SET:
registerDoMC(NUM_CORES) ##Set the total number of cores to use in parallel (it should be less than the number of cores in your machine -1)
setwd(PATH_OF_YOUR_LOCAL_COPY) ##Set to main dir in your local copy. Example: /home/damiano/data/learning-similarity-functions

##UNCOMMENT the classifier to use and check the output dir of the learned similarity function:
#classifier <- "SVM_terms_jaccard" #SVM(terms_jaccard)
#classifier <- "SVM_all"  #SVM(all features)
tables.dir <- sprintf("./data/adjacency_matrix_%s", classifier)


dataset <- "test"
test.dir <- sprintf("./data/features/%s", dataset)
output.dir <- "./data/hac-results"

entity.files <- list.files(tables.dir, full.names=T)
entities <- c()

foreach (j=1:length(entity.files)) %dopar% {

  entity <- entity.files[j]
  print(entity)
  
  #Read  similarity matrix
  DF <- read.table(file=entity,header=T,sep='\t',comment.char="",quote="\"",colClasses="character")
  DF <- DF[with(DF, order(x, y)), ]
  
  #Convert similarities to dissimilarities:
  DF$value <- 1-as.double(DF$value)
  DF2 <- DF
  DF2$aux <- DF2$x
  DF2$x <- DF2$y
  DF2$y <- DF2$aux
  DF2 <- DF2[,1:3]
  DF <- rbind(DF,DF2)
  DT <- data.table(DF)
  table <- t(tapply(DT$value , list(DT$x,DT$y) , as.double ))
  distances <- as.dist(table)
  
  #Run the complete HAC
  hac<-hclust(distances, method = "single", members = NULL)
  

  #Consider different thresholds to generate the clustering outputs
  thresholds <-  quantile(hac$height, probs=seq(0,1,0.1))
  

  for (i in 1:length(thresholds)) {
    threshold <- thresholds[i]

    quantile <- names(thresholds)[i]
    
    #Obtain clustering output for the given threshold 
    result <- as.data.frame(cutree(hac,h=threshold))
    result <- cbind(rownames(result),result)
    result <- cbind(strsplit(entity,"/")[[1]][4],result)
    
    #Write clustering output using RepLab format
    names(result) <- c("entity_id","tweet_id","topic_detection")
    results.filename <- sprintf("%s/learned_function_%s_%s", output.dir, classifier, quantile)     
    write.table(result, file=results.filename, append=T, sep="\t",row.names=FALSE, col.names=FALSE)
  }
}

