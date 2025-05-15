#!/usr/bin/env python3
# Copyright 2025 ACCESS-NRI and contributors. See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0

####################################################
##                                                ## 
## This script creates masks of near land points  ##
##                                                ##
####################################################

# Description:
# This script processes WOA23 temperature and salinity data 
# to create initial condition files. It combines applies masks 
# to filter invalid data, calculates pressure, absolute salinity, 
# and conservative temperature.

# import modules
import sys
import numpy as np
import netCDF4 as nc
import datetime
from dateutil.relativedelta import relativedelta

from pathlib import Path
import sys

path_root = Path(__file__).parents[0]
sys.path.append(str(path_root)+"/initial_conditions_WOA23/ocean-ic/")
from regridder import util

# Usage: 
# python setup_WOA_initial_conditions.py <src_data_dir> <dst_data_dir>
# Example:
# python setup_WOA_initial_conditions.py /path/to/source/dir /path/to/destination/dir

src_data_dir = sys.argv[1]  # Source directory for WOA23 data, raw data stored in "/g/data/ik11/inputs/WOA23" 
dst_data_dir = sys.argv[2]  # Destination directory to save output files

print('Importing WOA23 raw data')
mon = ['01','02','03','04','05','06','07','08','09','10','11','12']
deepmon = ['13','13','13','14','14','14','15','15','15','16','16','16']

# in a climatology, with 365 day calendar, whats the day of the middle of each month
DAY_IN_MONTH = [
    15.5,45,74.5,105,135.5,166,196.5,227.5,258,288.5,319,349.5
]

i = 0
for mm in range(0, len(mon)):
    i = i+1
    # get upper ocean temp data:
    woa_file = src_data_dir+'woa23_decav_t'+mon[mm]+'_04.nc'
    print(woa_file)
    ncFile = nc.Dataset(woa_file)
    lat = ncFile.variables['lat'][...]
    depth_upper = ncFile.variables['depth'][...]
    lon = ncFile.variables['lon'][...]
    t_in_situ_upper = ncFile.variables['t_an'][0,...]
    ncFile.close()

    # get upper ocean salinity data:
    woa_file = src_data_dir+'woa23_decav_s'+mon[mm]+'_04.nc'
    print(woa_file)
    ncFile = nc.Dataset(woa_file)
    s_practical_upper = ncFile.variables['s_an'][0,...]
    ncFile.close()

    # get lower ocean temp data:
    woa_file = src_data_dir+'woa23_decav_t'+deepmon[mm]+'_04.nc'
    print(woa_file)
    ncFile = nc.Dataset(woa_file)
    depth_lower = ncFile.variables['depth'][...]
    t_in_situ_lower = ncFile.variables['t_an'][0,...]
    ncFile.close()
    
    # get lower ocean salinity data:
    woa_file = src_data_dir+'woa23_decav_s'+deepmon[mm]+'_04.nc'
    print(woa_file)
    ncFile = nc.Dataset(woa_file)
    s_practical_lower = ncFile.variables['s_an'][0,...]
    ncFile.close()
    
    # combine January for upper ocean with winter below 1500m:
    t_in_situ = np.copy(t_in_situ_lower)
    t_in_situ[:len(depth_upper),:,:] = t_in_situ_upper
    s_practical = np.copy(s_practical_lower)
    s_practical[:len(depth_upper),:,:] = s_practical_upper
    depth = depth_lower
    del t_in_situ_lower,t_in_situ_upper,s_practical_lower,s_practical_upper
   
    # mask t_in_situ and s_practical before doing calculations:
    t_in_situ = np.ma.masked_where(t_in_situ>1000,t_in_situ)
    s_practical = np.ma.masked_where(s_practical>1000,s_practical)
    
    # convert in situ temperature to conservative temperature:
    import gsw
    print('Calculating pressure from depth')
    longitude,latitude=np.meshgrid(lon,lat)
    depth_tile = (np.tile(depth,(len(lat),1))).swapaxes(0,1)
    pressure = gsw.p_from_z(-depth_tile,lat)
    pressure_tile = np.tile(pressure,(1440,1,1)).swapaxes(0,2).swapaxes(0,1)
    del pressure
    
    # having memory issues, so do level by level:
    s_absolute = np.zeros_like(s_practical)
    for kk in range(0,len(depth)):
    	if kk%10 == 0:
    		print('Calculating absolute salinity for level '+str(kk))
    	s_absolute[kk,:,:] = gsw.SA_from_SP(s_practical[kk,:,:],pressure_tile[kk,:,:],
    		longitude,latitude)
    del longitude,latitude
    
    print('Calculating conservative temperature from in situ temperature')
    t_conservative = gsw.CT_from_t(s_absolute,t_in_situ,pressure_tile)
    
    # save to netcdf
    save_file = dst_data_dir + 'woa23_decav_ts_'+mon[mm]+'_04.nc'
    print(save_file)
    ncFile = nc.Dataset(save_file,'r+')

	# convert months since to days for cf-compliance
    time_var = ncFile.variables['time']
    time_origin = util.get_time_origin(src_data_dir+'woa23_decav_t'+mon[mm]+'_04.nc')
    if ('months since' in time_var.units):
        bounds_month = ncFile.variables['climatology_bounds'][0].data
        td = [relativedelta(months=iMonth) for iMonth in bounds_month]
        bounds_day = [time_origin+iD for iD in td]
        ncFile.variables['climatology_bounds'][0,...]  = [
            (iDay-time_origin).days for iDay in bounds_day
        ]

    time_var[0] = DAY_IN_MONTH[mm]
    time_var.units = (
		"days since {}-{}-{} 00:00:00".format(str(time_origin.year).zfill(4),
                                              str(time_origin.month).zfill(2),
                                              str(time_origin.day).zfill(2))
    )
    ncFile.time_coverage_resolution = "P01M"

    # overwrite salinity with data including January near surface values:
    ncFile.variables['practical_salinity'][0,...] = s_practical
    ncFile.variables['practical_salinity'].cell_methods = 'area: mean depth: mean time: mean within years time: mean over years'
    
    # add variable for conservative temperature:
    t_var = ncFile.createVariable('conservative_temperature', 'f4', ('time','depth',\
                   'lat','lon'),fill_value=9.96921e+36)
    t_var.units = 'degrees celsius'
    t_var.standard_name = 'sea_water_conservative_temperature'
    t_var.long_name = 'conservative temperature calculated using teos10 from objectively'+\
    	' analysed mean fields for sea_water_temperature'
    t_var.cell_methods = 'area: mean depth: mean time: mean within years time: mean over years'
    t_var[0,:] = t_conservative

    now = datetime.datetime.now()

    # Add or update global attributes for metadata
    ncFile.setncattr('Conventions', 'CF-1.10')
    ncFile.delncattr('featureType')
    ncFile.delncattr('id')
    ncFile.setncattr('title', 'WOA23-derived temperature and salinity fields with conservative temperature')
    ncFile.setncattr('summary', 'Conservative temperature computed from in-situ temperature and practical salinity using TEOS-10 via the GSW library')
    ncFile.setncattr('source', 'Data derived from NOAA World Ocean Atlas 2023 (WOA23) objective analyses')
    ncFile.setncattr('history', f'{now.strftime("%Y-%m-%d %H:%M:%S")} - conservative_temperature and practical_salinity updated using setup_WOA_initial_conditions.py')

    ncFile.close()

