# Initial Condition Files for MOM Ocean Grids Using World Ocean Atlas 2023 (WOA23)

This repository contains the tools and scripts to generate initial condition files for MOM ocean grids from World Ocean Atlas 2023 (WOA23) data. The repository leverages Nic Hannah's `ocean-ic` code for interpolating the salt and temperature fields onto the 3D MOM ocean grids.

# Generate Initial Conditions

This script generates initial condition files for a specific MOM ocean grid using WOA23 data. The grid and data paths are provided as environment variables, execute the following script with the grid, input and output directories as a command-line argument:

`./make_initial_conditions.sh --vgrid <path_to_vgrid_file> --hgrid <path_to_hgrid_file> --input <path_to_input_directory> --output <path_to_output_directory>`

