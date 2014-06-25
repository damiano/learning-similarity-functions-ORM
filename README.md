Learning Similarity Functions for Topic Detection in Online Reputation Monitoring
=================================================================================

Code, data and results used for the [SIGIR'14](http://sigir.org/sigir2014/) paper "Learning Similarity Functions for Topic Detection in Online Reputation Monitoring" by [Damiano Spina](http://nlp.uned.es/~damiano), [Julio Gonzalo](http://nlp.uned.es/~julio) and [Enrique Amigó](http://nlp.uned.es/~enrique). See http://damiano.github.io/learning-similarity-functions-ORM/ for more info.

#Code and Data

##Code

###System Requirements
This software has been tested with the following libraries and versions:

>-  Python 2.7.5 (for the learning process and combination of similarities)
>-  R 3.0.1 (for Hierarchical Agglomerative Clustering, HAC and normalization for evaluation)
>-  Perl 5.8.8 (for evaluation)
>-  Bash (Unix shell, for evaluation)

####Python packages: 
>- nltk 2.0.4
>-  numpy 1.7.0
>-  scikit-learn 0.15-git
>-  scipy 0.14.0.dev-f846eb3

####R packages:
>- fastcluster 1.1.13
>- doMC 1.3.1
>- iterators 1.0.6
>- foreach 1.4.1
>- data.table 1.8.10 

###Scripts
We now describe the usage of each of the scripts in the different `code/*` folders.

####[code/learning-similarity-functions](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/code/learning-similarity-functions)

>####build_SVM.py
   Builds a SVM binary classifier. The confidence to the __true__ class is used as the learned similarity function. The Python script receives three arguments: the training sample .tsv file (`INPUT_SAMPLE_FILE`), the type of model (`MODEL TYPE`, __terms_jaccard__ or __all__) and the output file where the model will be written (`OUTPUT_MODEL_FILE`).
    
>__Usage:__   

        python build_SVM.py INPUT_SAMPLE_FILE MODEL_TYPE OUTPUT_MODEL_FILE
        python build_SVM.py ../../data/features/training_sample.tsv terms_jaccard SVM_terms_jaccard.pkl
        python build_SVM.py ../../data/features/training_sample.tsv all SVM_allfeatures.pkl

>####classify.py
   Given a binary classifier (previously trained by using the `build_SVM.py` script) and a pairwise represented dataset, it computes the similarity matrix for each of the given entities/test cases. It receives three parameters: the trained model (`TRAINED_MODEL_FILE`), the dir with the target dataset (`TEST_FEATURES_DIR`) and the output dir on which the similarity matrices will be written (`ADJACENY_MATRIX_OUTPUT_DIR`).

>__Usage:__   
        python classify.py TRAINED_MODEL_FILE TEST_FEATURES_DIR ADJACENY_MATRIX_OUTPUT_DIR
        python classify.py SVM_terms_jaccard.pkl ../../data/features/test ../../data/adjacency_matrix_SVM_terms_jaccard


####[code/clustering](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/code/clustering)
>####hac.R
Given a similarity matrix, it generates the clustering of the 

>####hac_singleFeatures.R
It computes the HAC from a given single feature (e.g., terms_jaccard).

####[code/evaluation](https://github.com/damiano/learning-similarity-functions-ORM/tree/master/code/evaluation)
>####removeUnavailableTweets.R
Normalizes the system outputs, remove those tweets that are not available in the gold standard file (`data/goldstandard/replab2013_topic_detection_goldstandard.dat`)
It 

>####evaluate.sh
Bash script that calls the Perl `EVAL_TOPICDETECTION_RS.pl` script to evaluate all the systems in `data/system-outputs` and writes the results in `data/evaluation-results`

>####EVAL_TOPICDETECTION_RS.pl

[Reliability & Sensitivity](http://dl.acm.org/citation.cfm?id=2484081)
[RepLab 2013 Evaluation Campaign](http://link.springer.com/chapter/10.1007%2F978-3-642-40802-1_31)

##Data

RepLab 2013 Dataset is available at http://nlp.uned.es/replab2013


###Features

pair_id: Ids of the two tweets in the pair, separated by an underscore (_).
entity_id: Id of the entity to which the tweets belong to.
dataset: Subset of the RepLab 2013 (either training or test).
label: Label of the pair (either true of false). True: both tweets belong to the same topic/cluster in the gold standard; False: tweets belong to different clusters.
terms_jaccard...time_days: Values for the similarity signals (see Section 2.3 for more information).


###Feature Combinations

###Topic Detection System Output (RepLab 2013 Format)

>- terms_jaccard_*
>- svm_all_*
>- svm_terms_jaccard_*

>- best_replab
>- temporal_twitter_LDA

####replab2013_goldstandard_topic_detection

###Evaluation

#Citation
Please cite the article below if you use this resources in your research:
>D.Spina, J.Gonzalo, E. Amig&oacute;  
>_[Learning Similarity Functions for Topic Detection in Online Reputation Monitoring](http://nlp.uned.es/~damiano/pdf/spina2014learning.pdf)_   
>37th ACM SIGIR Conference on Research and Development in Information Retrieval (SIGIR). 2014.   


##BibTex
    @inproceedings{spina2014learning,  
    title={Learning Similarity Functions for Topic Detection in Online Reputation Monitoring},  
    author={Spina, Damiano and Gonzalo, Julio and Amig{\'o}, Enrique},  
    booktitle={SIGIR '14: 37th international ACM SIGIR conference on Research and development in information retrieval},  
    year={2014},  
    organization={ACM}  
    }
    
