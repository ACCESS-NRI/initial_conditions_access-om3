#!/bin/csh -f
# Copyright 2023 ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

#==================================================================
# The meaning of woa23 data name: woa23_decav_sXX_04.nc 
# XX: 00 means annual mean, the whole depth
#     01-12 means monthly mean, only upper 1500m
#     13-16 means seasonal mean, 13 for Winter, 14 for Spring, 
#     				 15 for Summer, 16 for Autumn.
#     13-16 with the whole depth
#
# reproduce the monthly data based on seasonal data, then using
# the monthly mean data instead of data on the upper 1500m ocean.
#
# This script is doing:
# 1. extract the variable salinity 's_an' from seaonsal data 
#    to each month.
# 2. using 'ncks --mk_rec time' to add unlimited attribute of time.
# 3. rename salinity name from 's_an' to 'practical_salinity' 
# 4. using 'setup_WOA_initial_conditions.py' to processing the 
#    conservative temperature.
#==================================================================

source /etc/profile.d/modules.csh

module purge
module use /g/data/hh5/public/modules
module load conda/analysis3
module load nco

set src_dir = /g/data/ik11/inputs/WOA23
set dst_dir = /g/data/ik11/inputs/access-om3/woa23/monthly

mkdir -p $dst_dir

echo 'extract salinity'
ncks -v s_an $src_dir/woa23_decav_s13_04.nc $dst_dir/woa23_decav_ts_01_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_01_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_01_04.nc
ncks -v s_an $src_dir/woa23_decav_s13_04.nc $dst_dir/woa23_decav_ts_02_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_02_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_02_04.nc
ncks -v s_an $src_dir/woa23_decav_s13_04.nc $dst_dir/woa23_decav_ts_03_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_03_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_03_04.nc
ncks -v s_an $src_dir/woa23_decav_s14_04.nc $dst_dir/woa23_decav_ts_04_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_04_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_04_04.nc
ncks -v s_an $src_dir/woa23_decav_s14_04.nc $dst_dir/woa23_decav_ts_05_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_05_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_05_04.nc
ncks -v s_an $src_dir/woa23_decav_s14_04.nc $dst_dir/woa23_decav_ts_06_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_06_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_06_04.nc
ncks -v s_an $src_dir/woa23_decav_s15_04.nc $dst_dir/woa23_decav_ts_07_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_07_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_07_04.nc
ncks -v s_an $src_dir/woa23_decav_s15_04.nc $dst_dir/woa23_decav_ts_08_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_08_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_08_04.nc
ncks -v s_an $src_dir/woa23_decav_s15_04.nc $dst_dir/woa23_decav_ts_09_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_09_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_09_04.nc
ncks -v s_an $src_dir/woa23_decav_s16_04.nc $dst_dir/woa23_decav_ts_10_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_10_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_10_04.nc
ncks -v s_an $src_dir/woa23_decav_s16_04.nc $dst_dir/woa23_decav_ts_11_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_11_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_11_04.nc
ncks -v s_an $src_dir/woa23_decav_s16_04.nc $dst_dir/woa23_decav_ts_12_04.nc
ncks --mk_rec time $dst_dir/woa23_decav_ts_12_04.nc -o $dst_dir/test.nc
mv $dst_dir/test.nc $dst_dir/woa23_decav_ts_12_04.nc

echo 'rename salinity to practical_salinity'
@ mons =  1
@ mone =  12
@ imon = {$mons}
while ( $imon <= $mone )
echo "month = " {$imon}
ncrename -v s_an,practical_salinity $dst_dir/woa23_decav_ts_`printf "%02d" {$imon}`_04.nc
@ imon ++
end

echo 'processing conservative temperature'
time python3 setup_WOA_initial_conditions.py $src_dir/ $dst_dir/

