#!/bin/bash

while getopts "s:r:" flag; do
	case "${flag}" in
		s) sub_name=${OPTARG} ;; 
		r) base_dir=${OPTARG} ;; 

	esac
done
#sub_name="NDARINV1Z2F3AA0"

cd $base_dir/data/ABCD

cp /fs04/datasets/abcd/Package_1230109/fmriresults01/abcd-mproc-release5/"$sub_name"_baselineYear1Arm1_ABCD-MPROC-T1* . 

cp /fs04/datasets/abcd/Package_1230109/fmriresults01/abcd-mproc-release5/"$sub_name"_baselineYear1Arm1_ABCD-MPROC-rsfMRI* .

for file in $sub_name*.tgz; do
    tar -xzvf "$file"
done

rm $sub_name*.tgz
