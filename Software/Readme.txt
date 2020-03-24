There following files are in the same folder of this "Readme.txt"

smith_waterman.cpp 	: Software simulation and "out_golden.pattern" generation  (for testbench)
translation2input.py		: "in.pattern" generation (for testbench) from DNA sequence file.
DNA Sequence file spec:-------------------
				|
	start of file		|
_______________________________		|
[seq1](enter key)		T	|
[seq2](enter key)		S	|
_______________________________		|
	end of file			|
-----------------------------------------

Seq1 			: Example for DNA Sequence file



ATCG.csv			: The file is the look up table for each pair of ATCG
Look up table file spec:-------------------------
					|
	start of file			|
_______________________________			|
[items of Look up table]			|
[corr. score.]				|
...					|
...					|
[corr. score.]				|
_______________________________			|
	end of file				|
					|
Note:					|
[items of Look up table]: 			|
 1.row and column items should be symmetry.	|
 2.items don't need for seperation.		|
 3.items must be ONE character.		|
[corr. score.]				|
 1.scores need ','to seperate			|
 2.# of [corr. score] should be same as 		|
   # of items 				|	
-------------------------------------------------






How to use?
Step1. g++ smith_waterman.cpp -o SW
Step2. Enter command ./SW [Seqence file][Look up table]

Step3 python3 translation2input.py
Step4 input your DNA Sequence file name

