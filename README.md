Learning Similarity Functions for Topic Detection in Online Reputation Monitoring
=================================================================================

Code, data and results used for the [SIGIR'14](http://sigir.org/sigir2014/) paper "Learning Similarity Functions for Topic Detection in Online Reputation Monitoring" by [Damiano Spina](http://nlp.uned.es/~damiano), [Julio Gonzalo](http://nlp.uned.es/~julio) and [Enrique Amigó](http://nlp.uned.es/~enrique). See http://damiano.github.io/learning-similarity-functions-ORM/ for more info.

#Code

##System Requirements
This software has been tested with the following libraries and versions:

>-  Python 2.7.5 (for the learning process and combination of similarities)
>-  R 3.0.1 (for Hierarchical Agglomerative Clustering, HAC and normalization for evaluation)
>-  Perl 5.8.8 (for evaluation)
>-  Bash (Unix shell, for evaluation)

###Python packages: 
>- nltk 2.0.4
>-  numpy 1.7.0
>-  scikit-learn 0.15-git
>-  scipy 0.14.0.dev-f846eb3

###R packages:
>- fastcluster 1.1.13
>- doMC 1.3.1
>- iterators 1.0.6
>- foreach 1.4.1
>- data.table 1.8.10 

##Scripts
We now describe the usage of each of the scripts in the different `code/*` folders.

###[code/learning-similarity-functions](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/code/learning-similarity-functions)

>###build_SVM.py
   Builds a SVM binary classifier. The confidence to the __true__ class is used as the learned similarity function. The Python script receives three arguments: the training sample .tsv file (`INPUT_SAMPLE_FILE`), the type of model (`MODEL TYPE`, __terms_jaccard__ or __all__) and the output file where the model will be written (`OUTPUT_MODEL_FILE`).
    
>__Usage:__   

        python build_SVM.py INPUT_SAMPLE_FILE MODEL_TYPE OUTPUT_MODEL_FILE
        python build_SVM.py ../../data/features/training_sample.tsv terms_jaccard SVM_terms_jaccard.pkl
        python build_SVM.py ../../data/features/training_sample.tsv all SVM_allfeatures.pkl

>###classify.py
   Given a binary classifier (previously trained by using the `build_SVM.py` script) and a pairwise represented dataset, it computes the similarity matrix for each of the given entities/test cases. It receives four parameters: the trained model (`TRAINED_MODEL_FILE`), the type of model (`MODEL TYPE`, __terms_jaccard__ or __all__), the dir with the target dataset (`TEST_FEATURES_DIR`) and the output dir on which the similarity matrices will be written (`ADJACENY_MATRIX_OUTPUT_DIR`).

>__Usage:__   
        python classify.py TRAINED_MODEL_FILE MODEL_TYPE TEST_FEATURES_DIR ADJACENY_MATRIX_OUTPUT_DIR
        python classify.py SVM_terms_jaccard.pkl terms_jaccard ../../data/features/test ../../data/adjacency_matrix_SVM_terms_jaccard


###[code/clustering](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/code/clustering)
>###hac.R
Given a similarity matrix, it generates the HAC clustering in the official RepLab 2013 output format. It receives three parameters: the total number of cores to be used in parallel (`NUM_CORES`), the absolute path of the Github local copy (`PATH_OF_YOUR_LOCAL_COPY`), and the built similarity matrix (`classifier`). Note that the parameters of the have to be set in the R script. For each test case/entity, the scripts reads the similarity matrix, performs the HAC, and writes, for each different threshold, the system output to the `./data/results` directory.

>__Usage:__ The script can be run using the `source(hac.R)` command in an R shell.



>###hac_singleFeatures.R
Analgously to the previous script, it computes the HAC from a given set of single features (e.g., `{terms_jaccard, semantics_jaccard}`). It receives three parameters: the total number of cores to be used in parallel (`NUM_CORES`), the absolute path of the Github local copy (`PATH_OF_YOUR_LOCAL_COPY`), and the list of features to be used. The possible features to be used are: 
     terms_jaccard, terms_lin_tfidf, terms_lin_cf, semantic_jaccard, semantic_lin_tfidf, semantic_lin_cf,  metadata_author,  metadata_hashtags, metadata_urls, metadata_namedusers, time_millis, time_hours, time_days
Likewise, the parameters have to be manually instantiated inside the R script.

>__Usage:__ The script can be run using the `source(hac_singleFeatures.R)` command in an R shell.

####[code/evaluation](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/code/evaluation)
>###removeUnavailableTweets.R
This R script normalizes the system outputs, removing those tweets that are not available in the gold standard file (`data/goldstandard/replab2013_topic_detection_goldstandard.dat`).

>###evaluate.sh
Bash script that calls the Perl `EVAL_TOPICDETECTION_RS.pl` script to evaluate all the systems in `data/system-outputs` and writes the results in `data/evaluation-results`

>###EVAL_TOPICDETECTION_RS.pl

This Perl script computes the official evaluation metrics for the [RepLab 2013 Topic Detection Task](http://link.springer.com/chapter/10.1007%2F978-3-642-40802-1_31): Reliability (R), Sensitivity (S), and the F-Score of R and S.[Reliability & Sensitivity](http://dl.acm.org/citation.cfm?id=2484081).


#Data

Note that this package does only contain the minimal data needed to reproduce the experiments presented in the paper. The RepLab 2013 Dataset is available at http://nlp.uned.es/replab2013


##[data/features](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/data/features)

This directory contains the feature representation for the training and test datasets. Due to the space limit on Github, the files are allocated in another server and can be downloaded from the following links:

>-Training set: http://nlp.uned.es/~damiano/datasets/learning-similarity-functions-ORM/data/features/training.tar.gz
>-Test set: http://nlp.uned.es/~damiano/datasets/learning-similarity-functions-ORM/data/features/test.tar.gz

The data is represented in tab-separated value files. Each file corresponds to an entity in the RepLab 2013 Dataset. Each row in a file correspond to a different pair of tweet (i.e., an instance) and columns are organized as follows:

>- __pair_id__: Ids of the two tweets in the pair, separated by an underscore (_).
>- __entity_id__: Id of the entity to which the tweets belong to.
>- __dataset__: Subset of the RepLab 2013 (either training or test).
>- __label__: Label of the pair (either true of false). True: both tweets belong to the same topic/cluster in the gold standard; False: tweets belong to different clusters.
>- __terms_jaccard...time_days__: Values for the similarity signals (see Section 2.3 of the paper for more information).


The gzipped `./data/training_samples.tsv.gz` file contains random samples from the training set that can be used to learn a similarity function.

##[data/goldstandard](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/data/goldstandard)

The `replab2013_topic_detection_goldstandard.dat` represents the gold standard of the RepLab 2013 Topic Detection Task used to perform the evaluation in this paper. It consists of a tab-separated value file where each row is a tweet and columns are:
>- __entity_id__: Id of the entity (test case) to which the tweet belongs to.
>- __tweet_id__: Id of the tweet.
>- __topic__: Name of the topic where the tweet was manually assigned to.

##[data/system-outputs](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/data/system-outpus)

This directory contains the output in the RepLab 2013 format of the different topic detection systems (and different cut-offs) proposed on the paper, as well as the official RepLab systems used to compare with.

>- terms_jaccard_*: HAC results for different cut-off thresholds when using the terms_jaccard feature as similarity function.
>- svm_all_*: HAC results for different cut-off thresholds when using the SVM(all features) learned similarity function.
>- svm_terms_jaccard_*: HAC results for different cut-off thresholds when using the SVM(terms_jaccard) learned similarity function.

>- best_replab: Best RepLab 2013 system (equivalent to semantic_jaccard) [Spina et al., 2013](http://nlp.uned.es/~damiano/pdf/replab2013-UNED-ORM.pdf).
>- temporal_twitter_LDA: Temporal Twitter-LDA system in RepLab 2013 [Spina et al., 2013](http://nlp.uned.es/~damiano/pdf/replab2013-UNED-ORM.pdf).

##[data/evaluation-results](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/data/evaluation-results)

#Citation
Please cite the article below if you use these resources in your research:
>D.Spina, J.Gonzalo, E. Amig&oacute;  
>_[Learning Similarity Functions for Topic Detection in Online Reputation Monitoring](http://nlp.uned.es/~damiano/pdf/spina2014learning.pdf)_   
>Proceedings of the 37th ACM SIGIR Conference on Research and Development in Information Retrieval (SIGIR). 2014.   


##BibTex
    @inproceedings{spina2014learning,  
    title={Learning Similarity Functions for Topic Detection in Online Reputation Monitoring},  
    author={Spina, Damiano and Gonzalo, Julio and Amig{\'o}, Enrique},  
    booktitle={SIGIR '14: 37th international ACM SIGIR conference on Research and development in information retrieval},  
    year={2014},  
    organization={ACM}  
    }
    
