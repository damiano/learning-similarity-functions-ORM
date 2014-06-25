################################################################################################################
#   Learning Similarity Functions for Topic Detection in Online Reputation Monitoring
#   Damiano Spina, Julio Gonzalo, Enrique Amigó. SIGIR'14. 2014
#   
# Builds a SVM binary classifier. The confidence to the "true" class is used as the learned similarity function. 
#   The Python script receives three arguments: the training sample .tsv file (INPUT_SAMPLE_FILE), the type of model (MODEL TYPE, 'terms_jaccard' or 'all') and the output file where the model will be written (OUTPUT_MODEL_FILE).
#
# Usage: python build_SVM.py INPUT_SAMPLE_FILE MODEL_TYPE OUTPUT_MODEL_FILE
#        python build_SVM.py ../../data/features/training_sample.tsv terms_jaccard SVM_terms_jaccard.pkl
#        python build_SVM.py ../../data/features/training_sample.tsv all SVM_all_features.pkl
#################################################################################################################
import nltk, sys, numpy
from numpy import array
from sklearn.svm import SVC
from sklearn.decomposition import SparsePCA
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import Imputer
from sklearn import cross_validation
from sklearn import metrics
from sklearn.naive_bayes import GaussianNB
from sklearn import tree
from sklearn.externals import joblib
from multiprocessing import Process, Pool, Manager
from os import listdir
from os.path import isfile, join
from sklearn.externals import joblib
import csv
import argparse

def read_features(fname):
  X = []
  y = []
  entities = []
  ids = []
#0       1                 2      3       4                5                     6                    7                        8                       9
#pair_id entity_id       dataset label   terms_jaccard   terms_lin_tfidf  terms_lin_cf         semantics_jaccard        semantics_lin_tfidf semantics_lin_cf   
#10               11               12                13                   14                       15                 16 
#author   hahstags urls     namedusers       time_millis        time_hours    time_days
  with open(fname, 'rb') as f:
      reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_ALL)
      headers = reader.next()
      for l in reader:
	entity = l[1]
	instance_id = l[0]
        
        try:
          label = int(l[3])
        except ValueError:
          label = 1 if l[3] else 0
        features = map(float,l[4:])
        
        entities.append(entity)
        ids.append(instance_id)
        X.append(features)
        y.append(label)
        
      
  return (ids,entities,X,y)
    
    
   
def worker(entity_filename, output_filename, clf):

        (ids_test, entities_test, features_test, label_test) = read_features(entity_filename)
        features_test_subset = [ [x[0]] for x in features_test]

        
        result = zip(ids_test,clf.predict_proba(features_test_subset))
        
        print "Result for entity ", entity_filename, " ready. Writing file..."
        
        
        f = file(output_filename, 'w')
        f.write("x\ty\tvalue\n")
        for (id,confidence) in result:
             (x,y) = tuple(id.split("_"))
             f.write("%s\t%s\t%f\n"%(x,y,confidence[1]))
        print "Closing file ",output_filename
        f.close()
        

def main():

    training_filename = sys.argv[1]

    (ids_training, entities_training, features_training, label_training) = read_features(training_filename)

    features_training_subset = [ [x[0]] for x in features_training]    

    clf = SVC(kernel="linear",class_weight="auto",probability=True)
   
    print "Building model..."

    if (sys.args[2] == "all"):
       model = clf.fit(features_training,label_training)
    else:
       model = clf.fit(features_training_subset, label_training)
    
    print "Storing model..."
    joblib.dump(clf, sys.argv[3], compress=9)
   
if __name__ == '__main__':
    main()
