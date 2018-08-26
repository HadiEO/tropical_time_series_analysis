// Adapted from ExportImageTimeStackLandsat
// In my GEE this script named "CheckAvailableSentinel2"

// Case study area for image stack export
var extent = ee.FeatureCollection("users/hadicu06/extent_DG_1"); 
Map.addLayer(extent, {}, 'extent');

var caseStudyArea = extent;                          // Change study area here!!!
Map.addLayer(caseStudyArea, {}, 'caseStudyArea');
Map.centerObject(caseStudyArea);

var S2_BANDS_NO = ['QA60', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12'];
var S2_BANDS_NAMES = ['QA60', 'blue', 'green', 'red', 'redEdge1', 'redEdge2', 'redEdge3', 'nirNarrow', 'nir', 'swir1', 'swir2'];


// create function to mask clouds using the Sentinel-2 QA band (from Nick Clinton)
// more advanced methods i.e. detecting shadows in https://code.earthengine.google.com/221cc0cf6cff8030493bab351d8376ec
var maskClouds = function(image){
  var qa = image.select('QA60');   
  
  // Bits 10 and 11 are clouds and cirrus, respectively
  var cloudBitMask = Math.pow(2, 10);
  var cirrusBitMask = Math.pow(2, 11);
  
  // Both flags should be set to zero, indicating clear conditions
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0).and(
    qa.bitwiseAnd(cirrusBitMask).eq(0));
    
  // Return the masked and scaled data
    return image.updateMask(mask)   
                .clip(caseStudyArea);                  // clip image to case study area
};

// Function to calculate Vegetation Indices
function addVI(image) {
  // var nbr = image.normalizedDifference(['nir', 'swir2']);
  var ndmi = image.normalizedDifference(['nir', 'swir1']);          // nbr or ndmi or ndvi
  // var ndvi = image.normalizedDifference(['nir', 'red']);
  // var evi = image.expression(
  //  '2.5 * (0.0001*NIR - 0.0001*R) / (0.0001*NIR + 6*0.0001*R - 7.5*0.0001*B + 1)',
  //  {
  //    R: image.select('red'),     
  //   NIR: image.select('nir'),     
  //    B: image.select('blue')     
  //  });
  
  return image.select([]) // Need to return same image as input
              .addBands([ndmi])                                         // nbr or ndmi or ndvi or evi
              .rename(['ndmi']) // rename bands                         // nbr or 'ndmi' or ndvi or evi
              .copyProperties(image, image.propertyNames());
} 


// Function to get scene id
var scene_ids = function(coll) {
    return coll.toList(coll.size(), 0).map(function(im) {
      // Get the image ID and strip off the first four chars '1_1_'
      // Untested other than this script 
      return ee.String(ee.Image(im).id());
    });
  };


//**********************************************************************************
// Export *WITHOUT* cloud-masking
//**********************************************************************************

// Import S2 collections 
var myS2 = ee.ImageCollection('COPERNICUS/S2')
    .filterDate('2015-06-23', '2017-09-16')               
    .filterBounds(caseStudyArea)
    .select(S2_BANDS_NO, S2_BANDS_NAMES);                       
print(myS2, 'myS2');  

// Consider filtering the above by granule cloud percentage metadata
// .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20))

// Calculate Vegetation Indices
var myS2_addVI = myS2.map(addVI); 
print(myS2_addVI.first(), 'myS2_addVI.first()');

var vis = {palette: ['green', 'red'], min: 0.5};
Map.addLayer(ee.Image(myS2_addVI.first()).clip(caseStudyArea), vis, 'myS2_addVI.first()'); // this shows nothing cause the first date image is entirely not clear in the clip area

// From image collection to multiband image, rename bands as image dates
var empty = ee.Image().select();
var myS2_addVI_multiband = myS2_addVI.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['ndmi'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);                            // above nbr or ndmi or ndvi or evi 

print(myS2_addVI_multiband, 'myS2_addVI_multiband');
// Map.addLayer(ee.Image(landsat5VImultiband).select('2010-08-30'), {}, 'landsat5VImultiband_oneDate');

// Export multiband (multidates) image
// Export.image.toDrive({  // or toDrive
//  image: myS2_addVI_multiband,
//  description: 'Sentinel2NDMI_cloudUnmasked_DG_1',   // NBR or NDMI or NDVI or EVI; KalArea1 or KalArea2
//  region: caseStudyArea,
//  maxPixels: 1e12,
//  scale: 20             // Important! 20m common resolution, the 10m bands will be resampled?
//});


// The exported TIF loses band names (= dates), so need to save the band names
var sceneId = scene_ids(myS2_addVI);
print(sceneId, "sceneIdSentinel2");
// Not yet figure out how to export the list to Drive, so just copy from console to excel for now 


//**********************************************************************************
// Export *WITH* cloud-masking
//**********************************************************************************

// Import S2 collections 
var myS2_cloudMasked = ee.ImageCollection('COPERNICUS/S2')
    .filterDate('2015-06-23', '2017-09-16')               
    .filterBounds(caseStudyArea)
    .map(maskClouds)                          // Apply cloud masking function 
    .select(S2_BANDS_NO, S2_BANDS_NAMES);
                                            
print(myS2_cloudMasked, 'myS2_cloudMasked');  

// Calculate Vegetation Indices
var myS2_cloudMasked_addVI = myS2_cloudMasked.map(addVI); 
print(myS2_cloudMasked_addVI, 'myS2_cloudMasked_addVI');

var vis = {palette: ['green', 'red'], min: 0.5};
Map.addLayer(ee.Image(myS2_cloudMasked_addVI.first()), vis, 'myS2_cloudMasked_addVI.first()'); // this shows nothing cause the first date image is entirely not clear in the clip area

// From image collection to multiband image, rename bands as image dates
var empty = ee.Image().select();
var myS2_cloudMasked_addVI_multiband = myS2_cloudMasked_addVI.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['ndmi'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);                            // above nbr or ndmi or ndvi or evi                           // above nbr or ndmi or ndvi or evi 

print(myS2_cloudMasked_addVI_multiband, 'myS2_cloudMasked_addVI_multiband');
Map.addLayer(ee.Image(myS2_cloudMasked_addVI_multiband).select('2015-11-30'), {}, 'myS2_cloudMasked_addVI_multiband_oneDate');

// Export multiband (multidates) image
Export.image.toDrive({  // or toDrive
  image: myS2_cloudMasked_addVI_multiband,
  description: 'Sentinel2NDMI_cloudMasked_DG_1',   // NBR or NDMI or NDVI or EVI; KalArea1 or KalArea2
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 20             // Important! 20m common resolution, the 10m bands will be resampled?
});


// The exported TIF loses band names (= dates), so need to save the band names
var sceneId_cloudMasked = scene_ids(myS2_cloudMasked_addVI);
print(sceneId_cloudMasked, "sceneIdSentinel2_cloudMasked");
// Not yet figure out how to export the list to Drive, so just copy from console to excel for now 

