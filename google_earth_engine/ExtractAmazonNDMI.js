// Use new Landsat collection 
// Landsat pre-collection deprecated Feb 15, 2018
// Thus need to change the cloud masking code

// Study area
var samplingArea = ee.Geometry.Polygon(
  [[[-60, 0], [-70, 0], [-70, -10], [-60, -10]]]); 

// Draw geometry around area of interest
Map.centerObject(samplingArea, 8);
Map.addLayer(samplingArea, {}, 'samplingArea');

// For visualizing true colour
var viz_params_trueColor = {'bands':['red, green, blue'], 'min': 0, 'max': 2000};

// Need to change this
var Landsat_5_BANDS = ['B1',   'B2',    'B3',  'B4',  'B5',  'B7', 'pixel_qa'];
var Landsat_7_BANDS = ['B1',   'B2',    'B3',  'B4',  'B5',  'B7', 'pixel_qa'];
// var Landsat_8_BANDS = ['B2',   'B3',    'B4',  'B5',  'B6',  'B7', 'pixel_qa'];
var STD_NAMES = ['blue', 'green', 'red', 'nir', 'swir1', 'swir2', 'pixel_qa'];

// Function to mask image
// pixel_qa Bit 1: Clear pixel indicator.
// See https://code.earthengine.google.com/f6a9c9b1bf7e1c4548142418edae75cb
var maskNonClear = function(image){
  var clear = image.select('pixel_qa').bitwiseAnd(2).neq(0);    
  return image.updateMask(clear);   
};

// Small example for checking
var landsat5Check = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR')
    .filterDate('2000-06-01', '2000-06-07')                
    .select(Landsat_5_BANDS, STD_NAMES)                               
    .filterBounds(samplingArea).map(maskNonClear);                       
print(landsat5Check.size(), 'landsat5Check.size'); 
print(landsat5Check, 'landsat5Check');

var sceneCheck = ee.Image(landsat5Check.first());
Map.addLayer(sceneCheck, viz_params_trueColor, 'sceneCheck');
// Looks ok!


// Import L5 collections 
var landsat5 = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR')
    .filterDate('2000-06-01', '2000-06-07')                 // '2000-06-01', '2004-05-31'
    .select(Landsat_5_BANDS, STD_NAMES)                               
    .filterBounds(samplingArea).map(maskNonClear);                       
print(landsat5.size(), 'landsat5.size'); 
// print(landsat5, 'landsat5');


// Import L7 collections 
var landsat7 = ee.ImageCollection('LANDSAT/LE07/C01/T1_SR')
    .filterDate('2000-06-01', '2000-06-07')                 // '2000-06-01', '2004-05-31'                            
    .select(Landsat_7_BANDS, STD_NAMES)                                
    .filterBounds(samplingArea).map(maskNonClear);                       
print(landsat7.size(), 'landsat7.size');
// print(landsat7, 'landsat7');


// Import L8 collections (not available for 2000-2004)
// var landsat8 = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR')
//     .filterDate('2013-04-11', '2017-07-01')    
//     .select(Landsat_8_BANDS, STD_NAMES)
//     .filterBounds(samplingArea).map(maskNonClear);
// print(landsat8.size(), 'landsat8.size');

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Stack images in different sensors
//////////////////////////////////////////////////////////////////////////////////////////////////////
var landsat5n7 = landsat5.merge(landsat7);
print(landsat5n7.size(), 'landsat5n7.size');

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Update decision: mask to keep dense forest (> 90% tree cover)
//////////////////////////////////////////////////////////////////////////////////////////////////////
var HansenGfcProduct = ee.Image('UMD/hansen/global_forest_change_2016_v1_4').clip(samplingArea);
var HansenTreeCover2000 = HansenGfcProduct.select(['treecover2000']);

// Visualize the tree cover layer in green.
Map.addLayer(HansenTreeCover2000.updateMask(HansenTreeCover2000),
    {palette: ['000000', '00FF00'], max: 100}, 'HansenTreeCover2000');

// Create mask of tree cover > 90%
var denseTreeCover2000 = ee.Image(0).clip(samplingArea).where(HansenTreeCover2000.gt(90),1);
Map.addLayer(denseTreeCover2000, {}, 'denseTreeCover2000'); 

// Vectorize the dense forest mask. To be used in QGIS to generate randomly located points within it.
// Update: pretty big vector data, let's just randomly generate points within the MODIS tile since 
// 95% of the tile is terra firme forest.
// var denseTreeCover2000Vector = HansenTreeCover2000.clip(samplingArea).updateMask(denseTreeCover2000)
//        .reduceToVectors({
//           crs: HansenTreeCover2000.projection(),
//           scale: 1000,                              // Scale 30 m results in too many pixels
//           geometryType: 'polygon',
//           eightConnected: false
//         });
// Make a display image for the vectors, add it to the map
// var display = ee.Image(0).updateMask(0).paint(denseTreeCover2000Vector, '000000', 3);
// Map.addLayer(display, {palette: '000000'}, 'denseTreeCover2000Vector');

// Apply the tree cover mask to Landsat image collection
var keepDenseForest = function(image){
    return ee.Image(image).updateMask(denseTreeCover2000);     
};

var landsat5n7 = ee.ImageCollection(landsat5n7).map(keepDenseForest);

// Small example for checking
var landsat5CheckDenseTree = landsat5Check.map(keepDenseForest);
var sceneCheckDenseTree = ee.Image(landsat5CheckDenseTree.first());
Map.addLayer(sceneCheckDenseTree, viz_params_trueColor, 'sceneCheckDenseTree');

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Calculate NDMI
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Function to calculate Vegetation Index (choose index by uncommenting the lines inside function)
function addVI(image) {
  // var nbr = image.normalizedDifference(['nir', 'swir2']);
  var ndmi = image.normalizedDifference(['nir', 'swir1']);          
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

// Apply the function to calculate Vegetation Index to the merged Landsat image collection
var landsat5n7addVI = landsat5n7.map(addVI); 
print(landsat5n7addVI.size(), 'landsat5n7addVI.size()'); 
print(landsat5n7addVI.first(), 'landsat5n7addVI.first()');

// From image collection to multiband image, rename bands as scene id, for Landsat-5 image collection
var empty = ee.Image().select();
var landsat5n7VImultiband = landsat5n7addVI.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['ndmi'], [ee.String(image.get('LANDSAT_ID'))]));    
    }, empty);                            // above nbr or ndmi or ndvi or evi 

// print(ee.Image(landsat5n7VImultiband), 'ee.Image(landsat5n7VImultiband)');

// ********************************************************************************
// Stuck here hohoho!!!!!!!!!!!!!!!! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// ********************************************************************************
// Convert multiband image into image collection?
var landsat5n7VImultibandAsImgCol = ee.ImageCollection(ee.Image(landsat5n7VImultiband));
print(landsat5n7VImultibandAsImgCol, 'landsat5n7VImultibandAsImgCol');
print(landsat5n7VImultibandAsImgCol.first(), 'landsat5n7VImultibandAsImgCol.first()');
print(landsat5n7VImultibandAsImgCol.size(), 'landsat5n7VImultibandAsImgCol.size()');
Map.addLayer(ee.Image(landsat5n7VImultibandAsImgCol.first()), {min: -5, max: 0, palette: ['blue', 'green', 'orange']}, 'landsat5n7VImultibandAsImgCol.first()');



///////////////////////////////////////////////////////////////////////////////////////////////////////
// Stack images in different sensors
//////////////////////////////////////////////////////////////////////////////////////////////////////
// This doesn't work, and btw maybe let's not do that i.e. co-registering the images?
// var landsatVImultibandMerged = ee.Image(landsat5VImultiband).addBands(ee.Image(landsat7VImultiband)); // .merge(landsat8VISmultiband)
// print(landsatVImultibandMerged, 'landsatVImultibandMerged');
// Update: merge the image collections earlier

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Compute median by scene (date) and export
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Ok, this doesn't seem to be a good idea
// ( see https://groups.google.com/forum/#!searchin/google-earth-engine-developers/get$20number$20of$20bands|sort:date/google-earth-engine-developers/ryqCwentPtY/jJkPlneCBwAJ )
// or hard
// ( see https://groups.google.com/forum/#!searchin/google-earth-engine-developers/get$20number$20of$20bands|sort:date/google-earth-engine-developers/lTD05fGp2Vw/SnBv558xBwAJ )


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Thus, alternatively extract time series at randomly distributed points inside the MODIS tile
// This will also be useful to compare the temporal data density with Kalimantan on per pixel basis
//////////////////////////////////////////////////////////////////////////////////////////////////////
// To minimize probability of sampling the 5% non-terra firme pixels, 
// keep only pixels with > X% tree cover
// Do this before calculating Vegetation Index early on

var randomPoints = ee.FeatureCollection("users/hadicu06/MODIS_amazon_tile_h11v09_randomPoints_10000");
Map.addLayer(randomPoints, {}, 'randomPoints');

// Store lat/long as properties in randomPoints
var storeLonLat = function(feature) {
  return feature.set({lon: feature.geometry().coordinates().get(0)})
  .set({lat: feature.geometry().coordinates().get(1)});
};

var randomPoints = randomPoints.map(storeLonLat);

var values = landsat5n7VImultibandAsImgCol.map(function(i){                                
                return ee.Image(i).sampleRegions({
                  collection: randomPoints,
                  properties: ['lon','lat'],
                  scale: 30});
              })
              .flatten();
// print(values, 'values');

// Export 
// Export.table.toDrive({
//       collection: values,
//       description: 'extrL5n7AmazonOneTileTest7DaysRandom10000', // extrL5n7AmazonOneTile2000to2004Random10000
//      fileFormat: 'CSV'
// });

