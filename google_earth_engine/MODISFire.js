// Study area
var Kalimantan = /* color: #ffc82d */ee.Geometry.Polygon(
        [[[109.16015625, 2.1088986592431382],
          [108.8525390625, 1.5818302639606454],
          [108.5888671875, 0.7470491450051796],
          [108.7646484375, -0.13183582116662096],
          [109.072265625, -1.1425024037061522],
          [109.599609375, -1.4939713066293112],
          [109.775390625, -2.0210651187669897],
          [109.9072265625, -2.943040910055132],
          [110.654296875, -3.2502085616531686],
          [111.5771484375, -3.2502085616531686],
          [111.7529296875, -3.8204080831949407],
          [112.412109375, -3.601142320158722],
          [112.8515625, -3.4256915244180624],
          [113.4228515625, -3.6449998008920375],
          [114.2138671875, -3.8642546157213955],
          [114.521484375, -4.477856485570586],
          [115.1806640625, -4.214943141390639],
          [115.83984375, -4.127285323245357],
          [115.9716796875, -4.609278084409823],
          [116.455078125, -4.171115454867424],
          [116.6748046875, -3.7765593098768635],
          [116.71875, -3.074695072369682],
          [116.806640625, -2.460181181020993],
          [116.7626953125, -1.8893059628373186],
          [117.333984375, -1.318243056862001],
          [117.7294921875, -0.8349313860427057],
          [117.7734375, -0.3076157096439005],
          [117.9052734375, 0.26367094433665017],
          [118.4326171875, 0.5273363048115169],
          [119.00390625, 0.21972602392080884],
          [119.3115234375, 0.39550467153201946],
          [119.091796875, 1.4061088354351594],
          [118.8720703125, 1.7575368113083254],
          [118.4326171875, 2.1088986592431382],
          [118.30078125, 2.4162756547063857],
          [117.94921875, 2.943040910055132],
          [117.9931640625, 3.4695573030614724],
          [118.4326171875, 4.083452772038619],
          [117.9052734375, 4.521666342614804],
          [117.333984375, 4.784468966579362],
          [116.3232421875, 4.8282597468669755],
          [115.576171875, 4.434044005032582],
          [115.3125, 3.6888551431470478],
          [114.78515625, 3.074695072369695],
          [114.5654296875, 2.5040852618529215],
          [114.43359375, 1.8014609294680355],
          [113.90625, 1.6696855009865839],
          [113.3349609375, 1.9332268264771233],
          [112.8515625, 2.0210651187669897],
          [112.1923828125, 1.7575368113083254],
          [111.708984375, 1.4061088354351594],
          [111.09375, 1.3182430568620136],
          [110.4345703125, 1.4939713066293239],
          [110.0390625, 1.9332268264771233],
          [109.599609375, 2.3723687086440504]]]);

// Suonenjoki
var SuonenjokiArea = ee.FeatureCollection("users/hadicu06/Suonenjoki_study_area");           // Or Sumatera etc.. Change region here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Iran
var IlamArea = /* color: #98ff00 */ee.Geometry.Polygon(
        [[[46.43989562988281, 33.66366787319357],
          [46.446075439453125, 33.59849232171775],
          [46.51817321777344, 33.59620456486714],
          [46.51885986328125, 33.67338280811615],
          [46.44195556640625, 33.67166848756908]]]);
          
          
// Draw geometry around area of interest
var samplingArea = IlamArea;           

Map.centerObject(samplingArea, 8);

// var Landsat_5_BANDS = ['B1',   'B2',    'B3',  'B4',  'B5',  'B7', 'cfmask'];
// var STD_NAMES = ['blue', 'green', 'red', 'nir', 'swir1', 'swir2', 'cfmask'];

// Import MODIS fire collections 
var fireCol = ee.ImageCollection('MODIS/006/MOD14A2')
    // .select(Landsat_5_BANDS, STD_NAMES)                               
    .filterBounds(samplingArea);                       
print(fireCol.size(), 'fireCol.size'); 
print(fireCol, 'fireCol');

// var landsat5NirCount = landsat5.select('nir').count();
// print(landsat5NirCount, 'landsat5NirCount');
// Map.addLayer(landsat5NirCount, {min:0, max:260, palette: ['#FFFFFF', '#FF0000']}, 'landsat5 Count',0);


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Extract time series for points
//////////////////////////////////////////////////////////////////////////////////////////////////////
// var firePoints = ee.FeatureCollection("users/hadicu06/Crowdsourced_fires_and_burn_scars_Kal_rand100");
// var firePoints = ee.FeatureCollection("users/hadicu06/Suonenjoki_CC_plots_2015");

// Iran
var firePoints = ee.FeatureCollection.randomPoints(IlamArea, 50);


print(firePoints, 'firePoints');
Map.addLayer(firePoints, {}, 'firePoints');

// Store their lat/long as properties
var lonlat = function(feature) {
  return feature.set({lon: feature.geometry().coordinates().get(0)})
  .set({lat: feature.geometry().coordinates().get(1)});
};
var firePoints = firePoints.map(lonlat);

// Print time series chart
// var ts1a = ui.Chart.image.series(finalColIndices.select(['ndvi','evi','nir']), mySmallRegion, ee.Reducer.mean(), 500); // pixel size 500 m for our chosen MODIS product
// print(ts1a);

// Kalimantan
var values = fireCol.map(function(i){                                
                return ee.Image(i).sampleRegions({
                  collection: firePoints,
                  // properties: ['lon','lat'],
                  scale: 1000});
              })
              .flatten();
// print(values, 'values');

// Export 
Export.table.toDrive({ 
      collection: values,
      description: 'extrMOD14A2_Ilam',
     fileFormat: 'CSV'
});

