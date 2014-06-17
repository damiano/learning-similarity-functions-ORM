require(data.table)
require("foreach")
require("doMC")
require("fastcluster")

dataset <- "test"

#SVM(term_jaccard)
classifier <- "jaccard_SVM"

#SVM(all)
classifier <- "SVM"

registerDoMC(15)

tables.dir <- sprintf("../%s/adjacency_matrix_%s", dataset, classifier)

entity.files <- list.files(tables.dir, full.names=T)


entities <- c()
foreach (j=1:length(entity.files)) %dopar% {
  #for (entity in entity.files) {
  entity <- entity.files[j]
  print(entity)
  
  DF <- read.table(file=entity,header=T,sep='\t',comment.char="",quote="\"",colClasses="character")
  #Similarity to dissimilarity:
  DF <- DF[with(DF, order(x, y)), ]
  
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
  
  hac<-hclust(distances, method = "single", members = NULL)
  thresholds <-  quantile(hac$height, probs=seq(0,1,0.1))
  
  #foreach (i=1:length(thresholds)) %dopar% {
  for (i in 1:length(thresholds)) {
    threshold <- thresholds[i]
    quantile <- names(thresholds)[i]
    
    #dir.create(results.dir, overwrite=True, recursive=True)
    result <- as.data.frame(cutree(hac,h=threshold))
    result <- cbind(rownames(result),result)
    result <- cbind(strsplit(entity,"/")[[1]][4],result)
    names(result) <- c("entity_id","tweet_id","topic_detection")
    results.filename <- sprintf("../%s/results/topics_%s_%s", dataset, classifier, quantile)   
    #write result; overwrite
    
    write.table(result, file=results.filename, append=T, sep="\t",row.names=FALSE, col.names=FALSE)
  }
}

#HAC over single features:
setwd("/data/damiano/replab2013/analysis/topic_detection/pairwise-classification/dev")
registerDoMC(5)
#dataset <- "test"
dataset <- "training"
single.features <- c(5,8,7,10)

# test.dir <- sprintf("../%s/representation", dataset)
test.dir <- sprintf("../%s/representation", dataset)
entity.files <- list.files(test.dir, full.names=T)
#pair_id entity_id       dataset label   jaccard_words   lin_specificity_words  lin_cf_words         jaccard_wikified        lin_specificity_wikified lin_cv_wikified   
#11                                                                       15 
#common_author   common_hahstags common_urls     common_namedusers       time_millis_diff        time_hours_diff    time_days_diff


foreach (j=1:length(entity.files)) %dopar% {
  
  #for (entity in entity.files) {
  entity <- entity.files[j]
  
  
  samples <- read.table(file=entity,header=T,sep='\t',comment.char="",quote="\"",colClasses="character")
  print(entity)
  for(feature.index in single.features) {
    
    feature <- names(samples)[feature.index]
    
    DF <- as.data.frame(t(as.data.frame(strsplit(samples$pair_id,"_"))))
    DF$value <- samples[,feature.index]
    rownames(DF) <- NULL
    names(DF) <- c("x","y","value")
    
    
    #Similarity to dissimilarity:
    #DF <- DF[with(DF, order(x, y)), ]
    
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
    hac<-hclust(distances, method = "single", members = NULL)
    thresholds <-  quantile(hac$height, probs=seq(0,1,0.1))
    print(thresholds)
    #foreach (i=1:length(thresholds)) %dopar% {
    for (i in 1:length(thresholds)) {
      threshold <- thresholds[i]
      quantile <- names(thresholds)[i]
      
      #dir.create(results.dir, overwrite=True, recursive=True)
      result <- as.data.frame(cutree(hac,h=threshold))
      result <- cbind(rownames(result),result)
      result <- cbind(strsplit(entity,"/")[[1]][4],result)
      names(result) <- c("entity_id","tweet_id","topic_detection")
      feature.name <- sub("_","-",feature)
      #results.filename <- sprintf("../%s/results/topics_%s_%s", dataset, feature, quantile) 
      
      results.filename <- sprintf("../%s/results/topics_%s_%s", dataset, feature.name, quantile)   
      #write result; overwrite
      print(sprintf("writing to %s",results.filename))
      write.table(result, file=results.filename, append=T, sep="\t",row.names=FALSE, col.names=FALSE)
    }
  }
}
