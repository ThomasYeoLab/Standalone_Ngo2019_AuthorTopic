#!/usr/bin/env bash
# Written by Wu Jianxiao and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
#This function runs the make_xyzIndex_vol function to make index volumes for both the original MNI152 template and the normalised version

###########################################
#Define paths
###########################################

UTILITIES_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")/utilities

###########################################
#Main commands
###########################################

main(){
  matlab -nodesktop -nosplash -nojvm -r "addpath('$UTILITIES_DIR'); CBIG_RF_make_xyzIndex_vol('$template', '$output_dir', '$template_type'); exit"
}

###########################################
#Function usage
###########################################

#usage
usage() { echo "
Usage: $0 -p <template_type> -t <template> -o <output_dir>

This scripts create x/y/z index files in a volumetric template space as step 1 in RF approaches. In an index file, each voxel is assigned value based on the x/y/z RAS coordinate of the voxel.

REQUIRED ARGUMENTS:
	-p <template_type> 	type of volumetric template to use. Input to this option is also used as prefix of output files.
				Possible options are:
				'MNI152_orig': use FSL_MNI152 1mm template
				'MNI152_norm': use FSL MNI152 1mm template's normalised volume generated by FreeSurfer's recon-all process
				'Colin27_orig': use SPM_Colin27 1mm template
				'Colin27_norm': use SPM_Colin27 1mm template's normalised volume generated by FreeSurfer's recon-all process
				others: use user-defined volumetric template file. In this case, input to this option an be any string; the user is expected to provide a template using "-t" option.

OPTIONAL ARGUMENTS:
	-t <template> 		absolute path to user-defined volumetric template file 
				[ default: unset ]
	-o <output_dir>		absolute path to output directory 
				[ default: $(pwd)/results/index_MNI152 ]
	-h			display help message

OUTPUTS:
	$0 will create 3 output files in the output directory, corresponding to the x/y/z index files. 
	For example: 
		MNI152_norm_x.INDEX.nii.gz
		MNI152_norm_y.INDEX.nii.gz
		MNI152_norm_z.INDEX.nii.gz
	 
EXAMPLE: 
	$0 -p 'MNI152_orig'
	$0 -p 'my_template' -t path/to/my/template.nii.gz

" 1>&2; exit 1; }

#Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

###########################################
#Parse arguments
###########################################

#Default parameters
output_dir=$(pwd)/results/index_MNI152

#Assign arguments
while getopts "p:t:o:h" opt; do
  case $opt in
    p) template_type=${OPTARG} ;;
    t) template=${OPTARG} ;;
    o) output_dir=${OPTARG} ;;
    h) usage; exit ;;
    *) usage; 1>&2; exit 1 ;;
  esac
done

#Set up default type templates
case $template_type in
  MNI152_norm)
    template=$CBIG_CODE_DIR/data/templates/volume/FSL_MNI152_FS4.5.0/mri/norm.nii.gz ;;
  MNI152_orig)
    template=$FSL_DIR/data/standard/MNI152_T1_1mm_brain.nii.gz ;;
  Colin27_norm)
    template=$CBIG_CODE_DIR/data/templates/volume/SPM_Colin27_FS4.5.0/mri/norm.mgz ;;
  Colin27_orig)
    template=$CBIG_CODE_DIR/data/templates/volume/SPM_Colin27_FS4.5.0/mri/orig/001.mgz ;;
esac

###########################################
#Check parameters
###########################################
  
if [ -z $template_type ]; then
  echo "Template type not defined."; 1>&2; exit 1;
fi

if [ -z $template ]; then
  echo "User-defined template is not provided."; 1>&2; exit 1
fi

###########################################
#Other set-ups
###########################################

#Make sure output directory is set up
if [ ! -d "$output_dir" ]; then
  echo "Output directory does not exist. Making directory now..."
  mkdir -p $output_dir
fi

###########################################
#Implementation
###########################################

main


