// Run task for each VHSR scene i.e. change:
// nowGeometry, nowPoints, fileName


// VHSR extents
var extentDG1 = ee.FeatureCollection("users/hadicu06/extent_DG_1");
var extentDG2 = ee.FeatureCollection("users/hadicu06/extent_DG_2");
var extentSC1 = ee.FeatureCollection("users/hadicu06/extent_SC_1");
var extentSQ9 = ee.FeatureCollection("users/hadicu06/square_9");
var extentSQ13 = ee.FeatureCollection("users/hadicu06/square_13");

Map.addLayer(extentDG1, {}, 'extentDG1');  
Map.addLayer(extentDG2, {}, 'extentDG2');  
Map.addLayer(extentSC1, {}, 'extentSC1');  
Map.addLayer(extentSQ9, {}, 'extentSQ9');  
Map.addLayer(extentSQ13, {}, 'extentSQ13');  

// Intact forest points
var intactDG1 = ee.FeatureCollection("users/hadicu06/pixels_DG1_intact_centers");
var intactDG2 = ee.FeatureCollection("users/hadicu06/pixels_DG2_intact_centers");
var intactSC1 = ee.FeatureCollection("users/hadicu06/pixels_SC1_intact_centers");
var intactSQ9 = ee.FeatureCollection("users/hadicu06/pixels_sq9_intact_centers");
var intactSQ13 = ee.FeatureCollection("users/hadicu06/pixels_sq13_intact_centers");

Map.addLayer(intactDG1, {}, 'intactDG1');  
Map.addLayer(intactDG2, {}, 'intactDG2');  
Map.addLayer(intactSC1, {}, 'intactSC1');  
Map.addLayer(intactSQ9, {}, 'intactSQ9');  
Map.addLayer(intactSQ13, {}, 'intactSQ13');  


// Function to mask image from clouds etc.
var maskNonClear = function(image){
  var clear = image.select('pixel_qa').bitwiseAnd(2).neq(0);    
  return image.updateMask(clear);   
};

// Rename image layers
var L5_BANDS = ['B1',   'B2',    'B3',  'B4',  'B5',  'B7', 'pixel_qa'];
var L7_BANDS = ['B1',   'B2',    'B3',  'B4',  'B5',  'B7', 'pixel_qa'];
var STD_NAMES = ['blue', 'green', 'red', 'nir', 'swir1', 'swir2', 'pixel_qa'];

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Get images
//////////////////////////////////////////////////////////////////////////////////////////////////////
var nowGeometry = extentSQ13.geometry();              // Which VHSR extent?
Map.centerObject(extentSQ13);

// Get Landsat 5
var L5 = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR')
    .filterDate('2000', '2004')
    .select(L5_BANDS, STD_NAMES)
    .filterBounds(nowGeometry)                    
    .map(maskNonClear);
print(L5.size(), 'L5.size()'); 

// Display image to check    
Map.addLayer(ee.Image(L5.first()), 
  {'bands':['red, green, blue'], 'min': 0, 'max': 2000}, 
  'L5.first()');
  
// Get Landsat 7
var L7 = ee.ImageCollection('LANDSAT/LE07/C01/T1_SR')
    .filterDate('2000', '2004')
    .select(L7_BANDS, STD_NAMES)
    .filterBounds(nowGeometry)                    
    .map(maskNonClear);
print(L7.size(), 'L7.size()'); 

// Display image to check    
Map.addLayer(ee.Image(L7.first()), 
  {'bands':['red, green, blue'], 'min': 0, 'max': 2000}, 
  'L7.first()');
    
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Stack images in different sensors
//////////////////////////////////////////////////////////////////////////////////////////////////////
var L5n7 = L5.merge(L7);
print(L5n7.size(), 'L5n7.size()');
    
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Extract image values at points
//////////////////////////////////////////////////////////////////////////////////////////////////////
var nowPoints = intactSQ13;                           // Which points?

// Store lat/long as properties in randomPoints
var storeLonLat = function(feature) {
  return feature.set({lon: feature.geometry().coordinates().get(0)})
  .set({lat: feature.geometry().coordinates().get(1)});
};

var nowPoints = nowPoints.map(storeLonLat);

var values = L5n7.map(function(i){                                
                return ee.Image(i).sampleRegions({
                  collection: nowPoints,
                  properties: ['Id', 'Id_new', 'Visual', 'lon', 'lat'],
                  scale: 30});
              })
              .flatten();
// print(values, 'values');

// Export 
var fileName = 'extrL5n7RawBandsKalimantan2000to2004_SQ13';  // Export name

Export.table.toDrive({
      collection: values,
      description: fileName, 
     fileFormat: 'CSV'
});

    