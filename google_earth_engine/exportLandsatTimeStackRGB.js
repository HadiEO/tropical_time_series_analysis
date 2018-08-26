// Case study area for image stack export
var KalArea1 = ee.FeatureCollection("users/hadicu06/overlay_Kal_area1");
var KalArea2 = ee.FeatureCollection("users/hadicu06/overlay_Kal_area2");

Map.addLayer(KalArea1, {}, 'KalArea1');
Map.addLayer(KalArea2, {}, 'KalArea2');


var caseStudyArea = KalArea1;                          // Change study area here!!!

var Landsat_5_BANDS = ['B1',   'B2',    'B3',  'B4',  'B5',  'B7', 'cfmask'];
var Landsat_7_BANDS = ['B1',   'B2',    'B3',  'B4',  'B5',  'B7', 'cfmask'];
var Landsat_8_BANDS = ['B2',   'B3',    'B4',  'B5',  'B6',  'B7', 'cfmask'];
var STD_NAMES = ['blue', 'green', 'red', 'nir', 'swir1', 'swir2', 'cfmask'];

// create function to mask clouds, cloud shadows, snow using the cfmask layer in SR products
var maskClouds = function(image){
  var cfmask = image.select('cfmask');    
  return image.updateMask(cfmask.lt(1))   // keep only clear pixels (cfmask = 0)
              .clip(caseStudyArea);       // clip image to case study area
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
var landsat5 = ee.ImageCollection('LANDSAT/LT5_SR')
    .filterDate('1984-01-01', '2012-05-05')               
    .select(Landsat_5_BANDS, STD_NAMES)                               
    .filterBounds(caseStudyArea).map(maskClouds);                       
print(landsat5.size(), 'landsat5.size()');  

// From image collection to multiband image, rename bands as image dates
// Blue
var empty = ee.Image().select();
var landsat5Multiband_blue = landsat5.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['blue'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

// Green
var empty = ee.Image().select();
var landsat5Multiband_green = landsat5.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['green'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

// Red
var empty = ee.Image().select();
var landsat5Multiband_red = landsat5.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['red'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

print(landsat5Multiband_blue, 'landsat5Multiband_blue');
Map.addLayer(ee.Image(landsat5Multiband_blue).select('2005-11-13'), {}, 'landsat5Multiband_blue');

print(landsat5Multiband_green, 'landsat5Multiband_green');

print(landsat5Multiband_red, 'landsat5Multiband_red');

// Export multiband (multidates) image
Export.image.toDrive({  // or toDrive
  image: landsat5Multiband_blue,                                                // blue
  description: 'landsat5Blue_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

Export.image.toDrive({  // or toDrive
  image: landsat5Multiband_green,                                               // green
  description: 'landsat5Green_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

Export.image.toDrive({  // or toDrive
  image: landsat5Multiband_red,                                                       // red
  description: 'landsat5Red_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});


// The exported TIF loses band names (= dates), so need to save the band names
var sceneId = scene_ids(landsat5);
print(sceneId, "sceneIdLandsat5");


////////////////////////////////////////////////////////////////////////////////////
// Landsat-7
////////////////////////////////////////////////////////////////////////////////////

// Import L7 collections 
var landsat7 = ee.ImageCollection('LANDSAT/LE7_SR')
    .filterDate('1999-01-01', '2017-08-31')                            
    .select(Landsat_7_BANDS, STD_NAMES)                                
    .filterBounds(caseStudyArea).map(maskClouds);                       
print(landsat7.size(), 'landsat7.size()');         

// From image collection to multiband image, rename bands as image dates
// Blue
var empty = ee.Image().select();
var landsat7Multiband_blue = landsat7.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['blue'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

// Green
var empty = ee.Image().select();
var landsat7Multiband_green = landsat7.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['green'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

// Red
var empty = ee.Image().select();
var landsat7Multiband_red = landsat7.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['red'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

print(landsat7Multiband_blue, 'landsat7Multiband_blue');
Map.addLayer(ee.Image(landsat7Multiband_blue).select('2010-02-04'), {}, 'landsat7Multiband_blue');

print(landsat7Multiband_green, 'landsat7Multiband_green');

print(landsat7Multiband_red, 'landsat7Multiband_red');

// Export multiband (multidates) image
Export.image.toDrive({  // or toDrive
  image: landsat7Multiband_blue,                                                // blue
  description: 'landsat7Blue_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

Export.image.toDrive({  // or toDrive
  image: landsat7Multiband_green,                                               // green
  description: 'landsat7Green_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

Export.image.toDrive({  // or toDrive
  image: landsat7Multiband_red,                                                       // red
  description: 'landsat7Red_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

// The exported TIF loses band names (= dates), so need to save the band names
var sceneId = scene_ids(landsat7);
print(sceneId, "sceneIdLandsat7");


////////////////////////////////////////////////////////////////////////////////////
// Landsat-8
////////////////////////////////////////////////////////////////////////////////////
// Import L8 collections 
var landsat8 = ee.ImageCollection('LANDSAT/LC8_SR')
    .filterDate('2013-04-11', '2017-08-31')    // ('2013-04-11', '2017-06-01') // ('2014-04-11', '2016-06-01')
    .select(Landsat_8_BANDS, STD_NAMES)
    .filterBounds(caseStudyArea).map(maskClouds);
print(landsat8.size(), 'landsat8.size()');     


// From image collection to multiband image, rename bands as image dates
// Blue
var empty = ee.Image().select();
var landsat8Multiband_blue = landsat8.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['blue'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

// Green
var empty = ee.Image().select();
var landsat8Multiband_green = landsat8.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['green'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

// Red
var empty = ee.Image().select();
var landsat8Multiband_red = landsat8.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['red'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);

print(landsat8Multiband_blue, 'landsat8Multiband_blue');
Map.addLayer(ee.Image(landsat8Multiband_blue).select('2015-11-25'), {}, 'landsat8Multiband_blue');

print(landsat8Multiband_green, 'landsat8Multiband_green');

print(landsat8Multiband_red, 'landsat8Multiband_red');

// Export multiband (multidates) image
Export.image.toDrive({  // or toDrive
  image: landsat8Multiband_blue,                                                // blue
  description: 'landsat8Blue_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

Export.image.toDrive({  // or toDrive
  image: landsat8Multiband_green,                                               // green
  description: 'landsat8Green_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

Export.image.toDrive({  // or toDrive
  image: landsat8Multiband_red,                                                       // red
  description: 'landsat8Red_bestDG_KalArea1',
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

// The exported TIF loses band names (= dates), so need to save the band names
var sceneId = scene_ids(landsat8);
print(sceneId, "sceneIdLandsat8");

// Not yet figure out how to export the list to Drive, so just copy from console to excel for now 
