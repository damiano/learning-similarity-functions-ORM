#############################################################################################################################
#   Learning Similarity Functions for Topic Detection in Online Reputation Monitoring
#   Damiano Spina, Julio Gonzalo, Enrique Amigó. SIGIR'14. 2014
#
#   Given a binary classifier (previously trained with the build_SVM.py script) and a pairwise represented dataset, it computes the similarity matrix for each of the given entities/test cases. 
#   It receives three parameters: the trained model (TRAINED_MODEL_FILE), the type of model (MODEL TYPE, 'terms_jaccard' or 'all'), the dir with the target dataset (TEST_FEATURES_DIR) and the output dir on which the similarity matrices will be written (ADJACENY_MATRIX_OUTPUT_DIR).
#  
#   Usage: python classify.py TRAINED_MODEL_FILE MODEL_TYPE TEST_FEATURES_DIR ADJACENY_MATRIX_OUTPUT_DIR
#          python classify.py SVM_terms_jaccard.pkl terms_jaccard ../../data/features/test ../../data/adjacency_matrix_SVM_terms_jaccard
#          python classify.py SVM_all_features.pkl all ../../data/features/test ../../data/adjacency_matrix_SVM_all_features
#############################################################################################################################

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
        
        
        if (sys.args[2] == "all"):
                result = zip(ids_test,clf.predict_proba(features_test))
        else:
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

#    training_filename = sys.argv[1]
#    (ids_training, entities_training, features_training, label_training) = read_features(training_filename)
#    features_training_subset = [ [x[0]] for x in features_training]    
#    clf = SVC(kernel="linear",class_weight="auto",probability=True)
  
    print "Reading built model..."
    model = joblib.load(sys.argv[1])
    
    test_dirname = sys.argv[3]
    
    p = Pool(15)
    
    for f in listdir(test_dirname):
        test_filename = join(test_dirname,f)
        test_output_filename = "%s/%s" % (sys.argv[4],f)
        p.apply_async(worker,[test_filename,test_output_filename,model])
        
          
    p.close()
    p.join()
    
if __name__ == '__main__':
    main()
