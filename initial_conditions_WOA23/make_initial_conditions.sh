#!/bin/bash
# Copyright 2025 ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

#PBS -q normal
#PBS -l mem=64Gb
#PBS -l walltime=48:00:00
#PBS -l jobfs=400GB
#PBS -l ncpus=8
#PBS -l wd
#PBS -l storage=gdata/hh5+gdata/ik11+gdata/tm70+gdata/vk83

GRIDDIR=$GRIDDIR
INPUT_DIR=$INPUT_DIR
OUTPUT_DIR=$OUTPUT_DIR

module purge
module use /g/data/hh5/public/modules
module load conda/analysis3
module load esmf

# Link grid files
ln -sf "${GRIDDIR}/ocean_hgrid.nc" ocean_hgrid.nc
ln -sf "${GRIDDIR}/ocean_vgrid.nc" ocean_vgrid.nc

PATH=./ocean-ic/:$PATH
echo $PATH

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Process each month
for ((i=1; i<=12; i++))
do
    printf -v mon "%02d" "${i}"
    INPUT_FILE="${INPUT_DIR}/woa23_decav_ts_${mon}_04.nc"
    OUTPUT_FILE="${OUTPUT_DIR}/woa23_ts_${mon}_mom.nc"

    echo "Processing: ${INPUT_FILE}"
    ln -sf "${INPUT_FILE}" input.nc

    makeic.py --use_mpi --mom_version MOM6 WOA input.nc input.nc input.nc input.nc MOM ocean_hgrid.nc ocean_vgrid.nc "${OUTPUT_FILE}"
done
