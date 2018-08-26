
// Case study area for image stack export
var extent = ee.FeatureCollection("users/hadicu06/extent_DG_1");  // square_1 is polygon (shp) imported into GEE Assets
Map.addLayer(extent, {}, 'extent');

var caseStudyArea = extent;                          // Change study area here!!!
Map.addLayer(caseStudyArea, {}, 'caseStudyArea');
Map.centerObject(caseStudyArea);

// create function to clip to study area
var clipToExtent = function(image){
  return image.clip(caseStudyArea);       // clip image to case study area
};

// Function to get scene id
var scene_ids = function(coll) {
    return coll.toList(coll.size(), 0).map(function(im) {
      // Get the image ID and strip off the first four chars '1_1_'
      // Untested other than this script 
      return ee.String(ee.Image(im).id());
    });
  };

////////////////////////////////////////////////////////////////////////////////////
// Landsat-5
////////////////////////////////////////////////////////////////////////////////////
// Import L5 collections 
var landsat5 = ee.ImageCollection('LANDSAT/LT05/C01/T1_TOA')
    .filterDate('1984-01-01', '2012-05-05')               
    .select('B6')                               
    .filterBounds(caseStudyArea);                       
print(landsat5.size(), 'landsat5.size()');  

var landsat5Clip = landsat5.map(clipToExtent);               // Clip to study area

var vis = {palette: ['green', 'red'], min: 0.5};
Map.addLayer(ee.Image(landsat5Clip.first()), vis, 'landsat5Clip.first()'); // this shows nothing cause the first date image is entirely not clear in the clip area

// From image collection to multiband image, rename bands as image dates
var empty = ee.Image().select();
var landsat5multiband = landsat5Clip.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['B6'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);                            

print(landsat5multiband, 'landsat5multiband');
// Map.addLayer(ee.Image(landsat5VImultiband).select('2010-08-30'), {}, 'landsat5VImultiband_oneDate');

// Export multiband (multidates) image
Export.image.toDrive({  
  image: landsat5multiband,
  description: 'landsat5thermal_DG_1',   
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});


// The exported TIF loses band names (= dates), so need to save the band names
var sceneId = scene_ids(landsat5Clip);
print(sceneId, "sceneIdLandsat5");
// Not yet figure out how to export the list to Drive, so just copy from console to excel for now 

////////////////////////////////////////////////////////////////////////////////////
// Landsat-7
////////////////////////////////////////////////////////////////////////////////////
// Import L7 collections 
var landsat7 = ee.ImageCollection('LANDSAT/LE07/C01/T1_TOA')
    .filterDate('1999-01-01', '2017-08-31')               
    .select('B6_VCID_2')                                   // high gain, more saturated                        
    .filterBounds(caseStudyArea);                       
print(landsat7.size(), 'landsat7.size()');  

var landsat7Clip = landsat7.map(clipToExtent);               // Clip to study area

var vis = {palette: ['green', 'red'], min: 0.5};
Map.addLayer(ee.Image(landsat7Clip.first()), vis, 'landsat7Clip.first()'); // this shows nothing cause the first date image is entirely not clear in the clip area

// From image collection to multiband image, rename bands as image dates
var empty = ee.Image().select();
var landsat7multiband = landsat7Clip.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['B6_VCID_2'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);                            

print(landsat7multiband, 'landsat7multiband');
// Map.addLayer(ee.Image(landsat5VImultiband).select('2010-08-30'), {}, 'landsat5VImultiband_oneDate');

// Export multiband (multidates) image
Export.image.toDrive({  
  image: landsat7multiband,
  description: 'landsat7thermal_DG_1',   
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});


// The exported TIF loses band names (= dates), so need to save the band names
var sceneId = scene_ids(landsat7Clip);
print(sceneId, "sceneIdLandsat7");
// Not yet figure out how to export the list to Drive, so just copy from console to excel for now 

////////////////////////////////////////////////////////////////////////////////////
// Landsat-8
////////////////////////////////////////////////////////////////////////////////////
// Import L8 collections 
var landsat8 = ee.ImageCollection('LANDSAT/LC08/C01/T1_TOA')
    .filterDate('2013-04-11', '2017-08-31')               
    .select('B10')                                   // 10.60 - 11.19 micrometer. B11 has stray light issue                       
    .filterBounds(caseStudyArea);                       
print(landsat8.size(), 'landsat8.size()');  

var landsat8Clip = landsat8.map(clipToExtent);               // Clip to study area

var vis = {palette: ['green', 'red'], min: 0.5};
Map.addLayer(ee.Image(landsat8Clip.first()), vis, 'landsat8Clip.first()'); // this shows nothing cause the first date image is entirely not clear in the clip area

// From image collection to multiband image, rename bands as image dates
var empty = ee.Image().select();
var landsat8multiband = landsat8Clip.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['B10'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);                            

print(landsat8multiband, 'landsat8multiband');
// Map.addLayer(ee.Image(landsat5VImultiband).select('2010-08-30'), {}, 'landsat5VImultiband_oneDate');

// Export multiband (multidates) image
Export.image.toDrive({  
  image: landsat8multiband,
  description: 'landsat8thermal_DG_1',   
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});


// The exported TIF loses band names (= dates), so need to save the band names
var sceneId = scene_ids(landsat8Clip);
print(sceneId, "sceneIdLandsat8");
// Not yet figure out how to export the list to Drive, so just copy from console to excel for now 

