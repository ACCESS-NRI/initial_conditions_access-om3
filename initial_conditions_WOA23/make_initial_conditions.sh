#!/bin/bash
# Copyright 2025 ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

# This script submits 12 jobs to the pbs scheduler, one for each month

HGRID=$HGRID
VGRID=$VGRID
INPUT_DIR=$INPUT_DIR
OUTPUT_DIR=$OUTPUT_DIR

# ---------------------------------
# Usage
# ---------------------------------
usage() {
    cat <<EOF
This script submits 12 jobs to the pbs scheduler, one for each month to make initial conditions from world ocean atlas

Usage: $0 -h <hgrid> -v <vgrid> -i <input_dir> -o <output_dir>

Required arguments:
  -h, --hgrid        Horizontal grid size
  -v, --vgrid        Vertical grid size
  -i, --input        Input directory
  -o, --output       Output directory

Example:
   ./make_initial_conditions.sh --vgrid /g/data/vk83/configurations/inputs/access-om3/mom/grids/vertical/global.25km/2025.03.12/ocean_vgrid.nc --hgrid /g/data/x77/ahg157/inputs/mom6/global-8km/ocean_hgrid.nc --input /g/data/ik11/inputs/access-om3/woa23/monthly/2025.10.24 --output /g/data/tm70/cyb561/8km_woa_ic 
EOF
    exit 1
}

# ---------------------------------
# Parse arguments
# ---------------------------------
[[ $# -eq 0 ]] && { echo "Error: No arguments provided."; usage; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--hgrid)
            HGRID="$2"
            shift 2
            ;;
        -v|--vgrid)
            VGRID="$2"
            shift 2
            ;;
        -i|--input)
            INPUT_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -help|--help|-H)
            usage
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            ;;
    esac
done

# ---------------------------------
# Validate required arguments
# ---------------------------------
[[ -z "$HGRID" ]]      && { echo "Error: --hgrid is required."; usage; }
[[ -z "$VGRID" ]]      && { echo "Error: --vgrid is required."; usage; }
[[ -z "$INPUT_DIR" ]]  && { echo "Error: --input is required."; usage; }
[[ -z "$OUTPUT_DIR" ]] && { echo "Error: --output is required."; usage; }

# ---------------------------------
# Export or use variables
# ---------------------------------
export HGRID VGRID INPUT_DIR OUTPUT_DIR

echo "Passed arguments are"
echo "HGRID=$HGRID"
echo "VGRID=$VGRID"
echo "INPUT_DIR=$INPUT_DIR"
echo "OUTPUT_DIR=$OUTPUT_DIR"

echo "All required arguments parsed successfully."

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

#this loop cycles over each month and submits a pbs job associated with each month
for ((i=1; i<=12; i++))
do

printf -v mon "%02d" "${i}"
INPUT_FILE="${INPUT_DIR}/woa23_decav_ts_${mon}_04.nc"
OUTPUT_FILE="${OUTPUT_DIR}/woa23_ts_${mon}_mom.nc"
echo ""
echo "Month, INPUT_FILE, OUTPUT_FILE: "
echo "${mon}, ${INPUT_FILE}, ${OUTPUT_FILE}"
echo ""

mkdir -p $i
cp -v submit_jobs_initial_conditions.sh $i/

cd $i
ln -sf "${INPUT_FILE}" input.nc

# Link grid files
ln -sf ${HGRID} ocean_hgrid.nc
ln -sf ${VGRID} ocean_vgrid.nc

##SUBMIT the job 
qsub -v VGRID="${VGRID}",HGRID="${HGRID}",INPUT_DIR="${INPUT_DIR}",OUTPUT_DIR="${OUTPUT_DIR}",OUTPUT_FILE="${OUTPUT_FILE}",INPUT_FILE="${INPUT_FILE}" -P $PROJECT submit_jobs_initial_conditions.sh

cd ..

done
