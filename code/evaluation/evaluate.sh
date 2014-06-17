#!/bin/bash
NUM_CORES=10 #Change the num. of parallel instances according to the number of cores on your machine
evaluate() {
             perl  ./EVAL_TOPICDETECTION_RS.pl ../../data/goldstandard/replab2013_topic_detection_goldstandard.dat ../../data/system-outputs/$1 > ../../data/evaluation-results/$1
          }
          export -f evaluate         
          parallel -P $NUM_CORES -u --gnu evaluate {1} ::: `ls ../../data/system-outputs`
