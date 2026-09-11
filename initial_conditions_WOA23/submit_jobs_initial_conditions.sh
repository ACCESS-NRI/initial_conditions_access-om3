#!/bin/bash
# Copyright 2025 ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

#PBS -q normal
#PBS -l mem=64Gb
#PBS -l walltime=22:00:00
#PBS -l jobfs=400GB
#PBS -l ncpus=8
#PBS -l wd
#PBS -l storage=gdata/xp65+gdata/ik11+gdata/tm70+gdata/vk83+gdata/x77

#passed grid and io information
HGRID=$HGRID
VGRID=$VGRID
INPUT_DIR=$INPUT_DIR
OUTPUT_DIR=$OUTPUT_DIR

#for each month input/output files
INPUT_FILE=$INPUT_FILE
OUTPUT_FILE=$OUTPUT_FILE

echo "Passed arguments are: "
echo "HGRID=$HGRID"
echo "VGRID=$VGRID"
echo "INPUT_DIR=$INPUT_DIR"
echo "OUTPUT_DIR=$OUTPUT_DIR"
echo "INPUT_FILE=$INPUT_FILE"
echo "OUTPUT_FILE=$OUTPUT_FILE"

module purge
module use /g/data/xp65/public/modules
module load conda/analysis3-26.08

PATH=../ocean-ic/:$PATH
echo $PATH

# Verify Pythran extension is used
PYTHONPATH="../ocean-ic${PYTHONPATH:+:${PYTHONPATH}}" \
    python3 -c 'import regridder.apply_weights as raw; print("Loaded:", raw.__file__)'

makeic.py --use_mpi --mom_version MOM6 WOA input.nc input.nc input.nc input.nc MOM ocean_hgrid.nc ocean_vgrid.nc "${OUTPUT_FILE}"

ncatted -h -O -a input_file,global,o,c,"$INPUT_FILE (md5sum: $(md5sum $INPUT_FILE | cut -f 1 -d ' '))" $OUTPUT_FILE
ncatted -h -O -a ocean_hgrid_file,global,o,c,"$HGRID (md5sum: $(md5sum $HGRID | cut -f 1 -d ' '))" $OUTPUT_FILE
ncatted -h -O -a ocean_vgrid_file,global,o,c,"$VGRID (md5sum: $(md5sum $VGRID | cut -f 1 -d ' '))" $OUTPUT_FILE
