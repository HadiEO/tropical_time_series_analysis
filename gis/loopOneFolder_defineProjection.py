# Description: Records the coordinate system information for the specified input dataset or feature class

# import system modules
import arcpy

# set workspace environment
arcpy.env.workspace = "C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data/digital_globe/SC_1"

# List the jpgs
jpgs = arcpy.ListRasters("*", "JPG")

# Specify target CRS by authiority code (EPSG). Can also by .prj, or recognized name, or from another spatial data (arcpy.Describe(), then .spatialReference) 
coord_sys = arcpy.SpatialReference(4326)

# Loop the jpgs and run the tool
for jpg in jpgs:
	arcpy.DefineProjection_management(jpg, coord_sys)
    
# print messages when the tool runs successfully
print(arcpy.GetMessages(0))