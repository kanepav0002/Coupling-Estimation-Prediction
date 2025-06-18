#!/bin/bash

cd /home/kanep/kg98_scratch/Kane/FC_estimations/code
sub_list=$(cat ../data/HCP/FINAL_LR_sub_list.txt)
sub_list=($sub_list)
base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations"

for i in {901..993}
do
	sub=${sub_list[$i]}
	sub_dir="data/HCP/$sub"
	sbatch estimate_FC_step2.sh -s $sub -d $sub_dir -r $base_dir
	echo $sub
done

