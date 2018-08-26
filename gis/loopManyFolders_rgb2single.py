# -*- coding: utf-8 -*-
"""
Created on Tue Jan 23 16:53:48 2018
Description: this script loops over jpgs which are true colour images (RGB) and convert
them to a single-layer GeoTiff with colourmap
@author: hadi1
"""

import arcpy
import os

# Folder that contain sub-folders to loop over within
arcpy.env.workspace = "C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data/digital_globe/FINALLY_USED"
# Test
# arcpy.env.workspace = "C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data/digital_globe/test_arcmap_loop"

# Don't display output in map
arcpy.env.addOutputsToMap = False

try:
    # List the sub-folders
    workspaces = arcpy.ListWorkspaces("*", "Folder")
    # Loop over the sub-folders
    for workspace in workspaces:
        # Set working directory
        arcpy.env.workspace = workspace
        # List the .jpgs
        jpgs = arcpy.ListRasters("*", "JPG")
        # Loop over the jpgs
        for jpg in jpgs:
            # Output geotiff name, inputName_suffix
            output_name = arcpy.Describe(jpg).baseName + "_copyRaster.tif"
            # Execute the CopyRaster tool
            # Check if jpg is 3-band RGB or single-band grayscale
            if arcpy.Describe(jpg).bandCount != 3:
                RGB_to_Colormap="NONE"
            else:
                RGB_to_Colormap="RGBToColormap"
            
            arcpy.CopyRaster_management(in_raster=jpg, 
                                        out_rasterdataset=os.path.join(workspace, output_name), 
                                        config_keyword="", background_value="", nodata_value="256", onebit_to_eightbit="NONE", colormap_to_RGB="NONE", pixel_type="", scale_pixel_value="NONE", 
                                        RGB_to_Colormap=RGB_to_Colormap, 
                                        format="TIFF", 
                                        transform="NONE")
        # Print messages when the tool runs successfully
        print(arcpy.GetMessages(0))
        
except arcpy.ExecuteError:
    print(arcpy.GetMessages(2))
    
except Exception as ex:
    print(ex.args[0])         