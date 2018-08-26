// Study area
var AmazonMODISTile = ee.Geometry.Polygon(
  [[[-60, 0], [-70, 0], [-70, -10], [-60, -10]]]); 

// Function to mask image
// pixel_qa Bit 1: Clear pixel indicator.
// See https://code.earthengine.google.com/f6a9c9b1bf7e1c4548142418edae75cb
var maskNonClear = function(image){
  var clear = image.select('pixel_qa').bitwiseAnd(2).neq(0);    
  return image.updateMask(clear);   
};

// Import L5 collection 
var Landsat_5_BANDS = ['B1',   'B2',    'B3',  'B4',  'B5',  'B7', 'pixel_qa'];
var STD_NAMES = ['blue', 'green', 'red', 'nir', 'swir1', 'swir2', 'pixel_qa'];

var landsat5MosaicSummer2000to2004 = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR')
    .filterDate('2000', '2004')
    .filter(ee.Filter.calendarRange(213, 243, 'day_of_year'))   // Aug month           
    .select(Landsat_5_BANDS, STD_NAMES)                               
    .map(maskNonClear)
    .mosaic();      

// For visualizing true colour
Map.addLayer(landsat5MosaicSummer2000to2004, {'bands':['red, green, blue'], 'min': 0, 'max': 2000}, 'landsat5Mosaic (true colour)');

// Show vector
Map.addLayer(AmazonMODISTile, {}, 'AmazonMODISTile');

// Show tree cover
var HansenGfcProduct = ee.Image('UMD/hansen/global_forest_change_2016_v1_4');
var HansenTreeCover2000 = HansenGfcProduct.select(['treecover2000']);

// Visualize the tree cover layer in green.
Map.addLayer(HansenTreeCover2000.updateMask(HansenTreeCover2000),
    {palette: ['000000', '00FF00'], min:0,  max: 100}, 'HansenTreeCover2000');

// Create mask of tree cover > 70%
var denseTreeCover2000 = ee.Image(0).where(HansenTreeCover2000.gt(70),1);
Map.addLayer(denseTreeCover2000, {}, 'denseTreeCover2000'); 

// Visualize the *dense* tree cover layer in green.
Map.addLayer(HansenTreeCover2000.updateMask(denseTreeCover2000),
    {palette: ['000000', '00FF00'], min:0,  max: 100}, 'HansenTreeCover2000 (dense)');

// Apply the tree cover mask to Landsat image collection
var keepDenseForest = function(image){
    return ee.Image(image).updateMask(denseTreeCover2000);     
};

var landsat5MosaicSummer2000to2004DenseForest = ee.ImageCollection(landsat5MosaicSummer2000to2004)
                                               .map(keepDenseForest);


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
var landsat5MosaicSummer2000to2004VI = ee.ImageCollection(landsat5MosaicSummer2000to2004)
                                    .map(addVI); 

var landsat5MosaicSummer2000to2004DenseForestVI = ee.ImageCollection(landsat5MosaicSummer2000to2004DenseForest)
                                    .map(addVI); 

// Show VI
Map.addLayer(landsat5MosaicSummer2000to2004DenseForestVI.select(['ndmi']),
    {palette: ['000000', '00FF00'], min:0.2,  max: 0.5}, 'Vegetation Index');
// '#99d8c9', '#31a354'


