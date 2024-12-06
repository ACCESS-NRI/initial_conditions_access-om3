#!/usr/bin/env sh

srcpath=/g/data/ik11/inputs/access-om3/woa23
dstpath=/g/data/ik11/inputs/access-om3/input_rc

echo "WARNING: About to copy initial conditions from ${srcpath} to ${dstpath}"
read -p "Proceed? (y/n) " yesno
case $yesno in
   [Yy] ) ;;
      * ) echo "Cancelled."; exit 0;;
esac

set -e
set -x

cp --preserve --remove-destination ${srcpath}/10/woa23_ts_01_mom10.nc   ${dstpath}/mom_1deg/ocean_temp_salt.res.nc
cp --preserve --remove-destination ${srcpath}/025/woa23_ts_01_mom025.nc ${dstpath}/mom_025deg/ocean_temp_salt.res.nc
cp --preserve --remove-destination ${srcpath}/01/woa23_ts_01_mom01.nc   ${dstpath}/mom_01deg/ocean_temp_salt.res.nc

echo "done"
