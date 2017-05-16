(defun create_model_by_validation (filename)
	(load "data-utilities.lisp")
        (load "deduce.lisp")
	(load "t-test.lisp")
	(load "universal-tester.lisp")
	(load "pfoil.lisp")

	(with-open-file (stream "accuracy-info.txt" :direction :output)
		(do
			((iteration 0 (+ iteration 1)))
			((= iteration 10) (close stream))

			(with-open-file (str1 "sample-soil-saved-tests.lisp" :direction :output :if-exists :supersede :if-does-not-exist :create)
			(close str1))
			(with-open-file (str2 "sample-soil-results-test" :direction :output :if-exists :supersede :if-does-not-exist :create)
			(close str2))
		
			(make-saved-tests "sample-soil-saved-tests.lisp" 11 80 10 40 filename)
			(delete-file "sample-soil-results-test")
			(create_train_and_test_set "sample-soil-saved-tests.lisp" 10)
			(run-saved-tests '(pfoil) "sample-soil-saved-tests-trainset.lisp" "sample-soil-results-test")			
		
			(cond
				 ((= iteration 0) 
					(copy-file "sample-soil-saved-tests-trainset.lisp" "sample-soil-saved-tests-best-trainset.lisp")
					(copy-file "sample-soil-saved-tests-testset.lisp" "sample-soil-saved-tests-best-testset.lisp")
					(copy-file "sample-soil-results-test" "sample-soil-results-test-best")
					(make-plot-file "sample-soil-results-test-best")
				
					(setq best_rules set_of_rules)
					(setq actualAccuracy (accuracy_result "sample-soil-results-test" "(80"))
					(setq bestAccuracy (accuracy_result "sample-soil-results-test-best" "(80"))
					(setq result (concatenate 'string "Iteratie: " (write-to-string (+ 1 iteration)) ", Accuratete actuala: "
					(write-to-string actualAccuracy) ", Cea mai buna acuratete: " (write-to-string bestAccuracy)))
					(format stream "~a~%" result))

				(T 
					(setq actualAccuracy (accuracy_result "sample-soil-results-test" "(80"))
					(setq bestAccuracy (accuracy_result "sample-soil-results-test-best" "(80"))
					(setq result (concatenate 'string "Iteratie: " (write-to-string iteration) ", Accuratete actuala: "
					(write-to-string actualAccuracy) ", Cea mai buna acuratete: " (write-to-string bestAccuracy)))
					(format stream "~a~%" result)
				
					(cond 
						((> actualAccuracy bestAccuracy) 
							(delete-file "sample-soil-saved-tests-best-trainset.lisp")
							(delete-file "sample-soil-saved-tests-best-testset.lisp")
							(delete-file "sample-soil-results-test-best")
							(setq best_rules set_of_rules)
							(copy-file "sample-soil-saved-tests-trainset.lisp" "sample-soil-saved-tests-best-trainset.lisp")
							(copy-file "sample-soil-saved-tests-testset.lisp" "sample-soil-saved-tests-best-testset.lisp")
							(copy-file "sample-soil-results-test" "sample-soil-results-test-best")
							(make-plot-file "sample-soil-results-test-best"))
						(T)
					)
					
				)
			)

			(delete-file "sample-soil-saved-tests-trainset.lisp")
			(delete-file "sample-soil-saved-tests-testset.lisp")
                        (delete-file "sample-soil-saved-tests.lisp")
			(delete-file "sample-soil-results-test")
		)
	)

       (metric_result "sample-soil-saved-tests-best-testset.lisp" best_rules)
)

(defun metric_result (filename rules &optional output-file (start-trial 1)
			training-increment  initial-training)
  
	(let (data-file)
    		(with-open-file (input filename :direction :input)
     		 (setf data-file (read input))
      			(if training-increment  (read input) (setf training-increment (read input)))
    			  (if initial-training (read input) (setf initial-training (read input)))
     				 (setf *saved-splits* (nthcdr  (1- start-trial) (read input))))
   	 (load-data data-file))
	 (setf test_example (cadr (multiple-value-bind (train test) (saved-example-generator) (list train test))))
	 (test-function-result test_example best_rules (float (length test_example)))
)

(defun test-function-result (examples rules total_examples)
	(do ((test_list examples) (nr-good-classification 0.0))
	    ((null test_list) (* (/ nr-good-classification total_examples) 100.0))
	    (setq classification_category (test-pfoil (car test_list) rules))
	    (if (eq (caar test_list) classification_category) (setf nr-good-classification (+ nr-good-classification 1.0)))
	    (setq test_list (cdr test_list)) 
	)
)

(defun copy-file (from to) 
   (with-open-file (stream_out to :direction :output)
	 (with-open-file (stream_in from) 
		 (do
  	  		((line (read-line stream_in nil) (read-line stream_in nil)))
			((null line) (close stream_in)  (close stream_out))
			(format stream_out "~a~%" line)
		)
	 )
   )
)


(defun accuracy_result (from training_number)
     (with-open-file (stream_from from)
	  (do
		((line (read-line stream_from nil))
		(accuracy 0.0) (value 0) (firstspace 0) (secondspace 0) (thirdspace 0) (forthspace 0) (dotindex 0) (nrOfLines 0.0))
		((null line) (close stream_from) (/ accuracy nrOfLines))

		(cond
		   ((string= "" line) (setf value 0.0))
                   (T 
			(cond 
			    ((string= (subseq line 1 4) training_number)
				(setf firstspace (search " " line))
				(setf secondspace (search " " line :start2 (+ firstspace 1)))
				(setf thirdspace (search " " line :start2 (+ secondspace 1)))
				(setf forthspace (search " " line :start2 (+ thirdspace 1)))
				(setf dotindex (search "." line :start2 (+ thirdspace)))
				(setf value (float (parse-integer (subseq line (+ 1 thirdspace) dotindex))))
				(setf nrOfLines (+ nrOfLines 1.0))
			    )
			    (T (setf value 0.0))
		   ))
		)
		
		(setf accuracy (+ accuracy value))
		(setf line (read-line stream_from nil))
	  )		
     )
)

(defun create_train_and_test_set (filename number-training)
	 (with-open-file (stream filename)  
		 (setq name (subseq filename 0 (search ".lisp" filename)))
                 (setq trainset_file (concatenate 'string name "-trainset.lisp"))
		 (setq testset_file (concatenate 'string name "-testset.lisp"))
		 (with-open-file (stream1 trainset_file :direction :output)
		 	 (with-open-file (stream2 testset_file :direction :output)	
		 		(do
		  	  		((line (read-line stream nil) (read-line stream nil)) (lineNr 1) (trainingIteration 0))
					((null line) (format stream1 "~a~%" ")")(close stream) (close stream1) (close stream2))
					(if (< lineNr 7) (format stream1 "~a~%" line))
					(if (< lineNr 7) (format stream2 "~a~%" line))
					(if (not (null (search "((" line))) (setq trainingIteration (+ trainingIteration 1)))
					(if (and (> lineNr 6) (>= number-training trainingIteration)) (format stream1 "~a~%" line))
					(if (> trainingIteration number-training) (format stream2 "~a~%" line))
					(setq lineNr (+ lineNr 1))
				)
			)
		)
	)
)
