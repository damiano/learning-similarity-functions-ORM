require(data.table)
require("foreach")
require("doMC")
require("fastcluster")

dataset <- "test"
NUM_CORES <- 15

registerDoMC(NUM_CORES)
setwd(...) #Set to main dir in your local copy. Example: /home/damiano/data/learning-similarity-functions
single.features <- c(5,8) #Column indexes in the .tsv file for the subset of features that will be considered for HAC (independently). For instance, index 5 corresponds to terms_jaccard, while index 8 corresponds to semantics_jaccard.

test.dir <- sprintf("../%s/representation", dataset)
output.dir <- "../../results"

entity.files <- list.files(test.dir, full.names=T)

foreach (j=1:length(entity.files)) %dopar% {
  
  entity <- entity.files[j]

  #Read pairwise representation file
  samples <- read.table(file=entity,header=T,sep='\t',comment.char="",quote="\"",colClasses="character")
  print(entity)

  #For each single feature in the subset
  for(feature.index in single.features) {
    
    feature <- names(samples)[feature.index]
    
    #Generate similarity matrix
    DF <- as.data.frame(t(as.data.frame(strsplit(samples$pair_id,"_"))))
    DF$value <- samples[,feature.index]
    rownames(DF) <- NULL
    names(DF) <- c("x","y","value")
    
    
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
    table[is.na(table)] <- 1
    distances <- as.dist(table)
    print(feature)

    #Run the complete HAC
    hac<-hclust(distances, method = "single", members = NULL)

    #Consider different thresholds to generate the clustering outputs
    thresholds <-  quantile(hac$height, probs=seq(0,1,0.1))
    print(thresholds)
    
    for (i in 1:length(thresholds)) {
      threshold <- thresholds[i]
      quantile <- names(thresholds)[i]
      
      #Obtain clustering output for the given threshold
      result <- as.data.frame(cutree(hac,h=threshold))
      result <- cbind(rownames(result),result)
      result <- cbind(strsplit(entity,"/")[[1]][4],result)
      
      #Write clustering output using RepLab format
      names(result) <- c("entity_id","tweet_id","topic_detection")
      feature.name <- sub("_","-",feature)
      results.filename <- sprintf("%s/single_features_%s_%s", output.dir, feature.name, quantile)   
      print(sprintf("writing to %s",results.filename))
      write.table(result, file=results.filename, append=T, sep="\t",row.names=FALSE, col.names=FALSE)
    }
  }
}
