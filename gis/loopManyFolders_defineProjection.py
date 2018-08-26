# Description: Records the coordinate system information for the specified input dataset or feature class

# import system modules
import arcpy


# set initial workspace environment
arcpy.env.workspace = "C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data/digital_globe/SC_1"
# arcpy.env.workspace = "H:/MyDocuments/Python/testData_loop_defineProjection"  # Test. OK

try:
    # Specify target CRS by authiority code (EPSG). Can also by .prj, or recognized name, or from another spatial data (arcpy.Describe(), then .spatialReference) 
    coord_sys = arcpy.SpatialReference(4326)

    # List workspaces i.e. directories
    workspaces = arcpy.ListWorkspaces("*", "Folder")

    # Loop workspaces and list the jpgs
    for workspace in workspaces:
        arcpy.env.workspace = workspace          # Change the environment workspace        
        jpgs = arcpy.ListRasters("*", "JPG")     # List the JPGs in new workspace

        # Loop the jpgs and run the tool
        for jpg in jpgs:
            arcpy.DefineProjection_management(jpg, coord_sys)
    
    # print messages when the tool runs successfully
    print(arcpy.GetMessages(0))
    
except arcpy.ExecuteError:
    print(arcpy.GetMessages(2))
    
except Exception as ex:
    print(ex.args[0])
