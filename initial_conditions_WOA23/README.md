# Initial Condition Files for MOM Ocean Grids Using World Ocean Atlas 2023 (WOA23)

This repository contains the tools and scripts to generate initial condition files for MOM ocean grids from World Ocean Atlas 2023 (WOA23) data. The repository leverages Nic Hannah's `ocean-ic` code for interpolating the salt and temperature fields onto the 3D MOM ocean grids.

# Generate Initial Conditions

This script generates initial condition files for a specific MOM ocean grid using WOA23 data. The grid and data paths are provided as environment variables, execute the following script with the grid, input and output directories as a command-line argument:

`./make_initial_conditions.sh --vgrid /g/data/vk83/configurations/inputs/access-om3/mom/grids/vertical/global.25km/2025.03.12/ocean_vgrid.nc --hgrid /g/data/x77/ahg157/inputs/mom6/global-8km/ocean_hgrid.nc --input /g/data/ik11/inputs/access-om3/woa23/monthly/2025.10.24 --output /g/data/tm70/cyb561/8km_woa_ic`

