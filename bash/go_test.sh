function normalize_text {
  awk '{print tolower($0);}' < $1 | LC_ALL=C sed -e 's/\./ \. /g' -e 's/<br \/>/ /g' -e 's/"/ " /g' \
  -e 's/,/ , /g' -e 's/(/ ( /g' -e 's/)/ ) /g' -e 's/\!/ \! /g' -e 's/\?/ \? /g' \
  -e 's/\;/ \; /g' -e 's/\:/ \: /g' > $1-norm
}

##curl -O http://ai.stanford.edu/~amaas/data/sentiment/aclImdb_v1.tar.gz
##tar -xf aclImdb_v1.tar.gz
## normalize the data
cd statements
for j in test_sentences; do
  rm temp
  rm $j/norm.txt
  for i in `ls $j`; do cat $j/$i >> temp; awk 'BEGIN{print;}' >> temp;
  done
  normalize_text temp
  mv temp-norm $j/norm.txt
done
#cat train/pos/norm.txt train/neg/norm.txt train/unsup/norm.txt test/pos/norm.txt test/neg/norm.txt > alldata.txt
## shuffle the training set
#gshuf alldata.txt > alldata-shuf.txt
cd ..

rm doc2vecc
gcc doc2vecc.c -o doc2vecc -lm -pthread -O3 -march=native -funroll-loops

# this script trains on all the data (train/test/unsup), you could also remove the test documents from the learning of word/document representation
time ./doc2vecc -train ./statements/test_sentences/norm.txt -word wordvectors_test.txt -output docvectors_test.txt -cbow 1 -size 256 -window 10 -negative 5 -hs 0 -sample 0 -threads 4 -binary 0 -iter 20 -min-count 10 -test ./statements/test_sentences/norm.txt -sentence-sample 0.1 -save-vocab alldata.vocab

#head -n 25000 docvectors.txt | awk 'BEGIN{a=0;}{if (a<12500) printf "1 "; else printf "-1 "; for (b=1; b<=NF; b++) printf b ":" $(b) " "; print ""; a++;}' > train.txt
#tail -n 25000 docvectors.txt | awk 'BEGIN{a=0;}{if (a<12500) printf "1 "; else printf "-1 "; for (b=1; b<=NF; b++) printf b ":" $(b) " "; print ""; a++;}' > test.txt
##C:\Users\Foroozan\AppData\Local\Programs\Python\Python37\Lib\site-packages\liblinear\train -s 0 train.txt model.logreg
##C:\Users\Foroozan\AppData\Local\Programs\Python\Python37\Lib\site-packages\liblinear\predict -b 1 test.txt model.logreg out.logreg
cd ..
