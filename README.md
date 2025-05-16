Tools to produce conservative temperature and salinity from World Ocean Atlas 2023 
data, and regrid them to the MOM model grids for use in ACCESS-OM3.

1. Run inte.csh to create temperature and salinity files, using monthly data 
instead of seasonal data in the upper 1500m. Results are put in 
/g/data/ik11/inputs/access-om3/woa23/monthly
Note: This step is only necessary if you want to change the WOA23 dataset to a different version. In that case, make sure to update the dataset path inside inte.csh accordingly. If you're generating initial conditions for a different resolution using the same WOA23 monthly data, you can skip this step and go directly to Step 2.

2. Run make_initial_conditions.sh in the directory initial_conditions_WOA/ to 
regrid temperature and salinity onto the ACCESS-OM3 horizontal and vertical grids.

3. If you're happy with the results, run finalise.sh to git commit and add commit 
info to the .nc metadata. You must provide the output path using the -o option. 
For example:`./finalise.sh -o /g/data/ik11/inputs/access-om3/woa23/025/`

This repository contains submodules, so clone it with

`git clone --recursive https://github.com/ACCESS-NRI/initial_conditions_access-om3.git`
