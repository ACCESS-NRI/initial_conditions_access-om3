#!/usr/bin/env sh
# Copyright 2025 ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0
# Commit changes and push, then add metadata to note how changes were made

module load nco
module load git

# Parse command-line options
while getopts "o:" opt; do
  case $opt in
    o) outpath="$OPTARG" ;;
    *) echo "Usage: $0 -o output_path"; exit 1 ;;
  esac
done

# Ensure output path is provided
if [ -z "$outpath" ]; then
  echo "Error: Output path is required."
  echo "Usage: $0 -o output_path"
  exit 1
fi

echo "Using output path: $outpath"

echo "About to commit all changes to git repository and push to remote."
read -p "Proceed? (y/n) " yesno
case $yesno in
   [Yy] ) ;;
      * ) echo "Cancelled."; exit 0;;
esac

set -x
set -e

git commit -am "update" || true
git push || true

for f in ${outpath}/${d}/woa23_ts_??_mom.nc; do
      ncatted -O -h -a history,global,a,c," | Created on $(date) using https://github.com/ACCESS-NRI/initial_conditions_access-om3.git/tree/$(git rev-parse --short HEAD)" $f
done

for f in ${outpath}/monthly/woa23_*.nc; do
      ncatted -O -h -a history,global,a,c," | Created on $(date) using https://github.com/ACCESS-NRI/initial_conditions_access-om3.git/tree/$(git rev-parse --short HEAD)" $f
done

set +e
chgrp -R ik11 ${outpath}
chmod -R g+rX ${outpath}

echo "done"
