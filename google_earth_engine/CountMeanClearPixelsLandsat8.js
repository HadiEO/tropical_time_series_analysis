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
          
Map.addLayer(Kalimantan, {}, 'Kalimantan');
Map.centerObject(Kalimantan);
          
// Function to mask image from clouds etc.
var maskNonClear = function(image){
  var clear = image.select('pixel_qa').bitwiseAnd(2).neq(0);    
  return image.updateMask(clear);   
};

// Rename image layers
var Landsat_8_BANDS = ['B2',   'B3',    'B4',  'B5',  'B6',  'B7', 'pixel_qa'];
var STD_NAMES = ['blue', 'green', 'red', 'nir', 'swir1', 'swir2', 'pixel_qa'];

// Get Landsat 8
var fromsL8 = ['2013-01-01', '2014-01-01', '2015-01-01',  '2016-01-01'];

var tosL8 = ['2013-12-31', '2014-12-31', '2015-12-31',  '2016-12-31'];

var landsat8CountMultiband;  // to store all the bands in the loop

var countAnnualSum_L8 = function(fromL8, toL8) {
  // do something for every year, and stack the result to the final multi-bands image.
   var landsat8 = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR')
                                  .filterDate(fromL8, toL8)          
                                  .select(Landsat_8_BANDS, STD_NAMES)                               
                                  .filterBounds(Kalimantan).map(maskNonClear); 

  var landsat8NirCount = landsat8.select('nir').count();
  var landsat8NirCountClip = landsat8NirCount.clip(Kalimantan).rename(currentName);
  
  return landsat8NirCountClip;
};



for (var i=0; i<fromsL8.length; i++) {                       // javascript indexing starts from 0 !
  var nowFromL8 = fromsL8[i];
  var nowToL8 = tosL8[i];
  var currentName = ee.String(nowFromL8).cat(' to ').cat(ee.String(nowToL8));
  // print(currentName);
  
  if (i===0) {
    landsat8CountMultiband = countAnnualSum_L8(nowFromL8, nowToL8);
  } else {
    landsat8CountMultiband = landsat8CountMultiband
                              .addBands(countAnnualSum_L8(nowFromL8, nowToL8));
    }
}

print(landsat8CountMultiband, 'landsat8CountMultiband');
Map.addLayer(landsat8CountMultiband.select('2013-01-01 to 2013-12-31'), {}, 'landsat8CountMultiband_2013');
Map.addLayer(landsat8CountMultiband.select('2014-01-01 to 2014-12-31'), {}, 'landsat8CountMultiband_2014');
Map.addLayer(landsat8CountMultiband.select('2015-01-01 to 2015-12-31'), {}, 'landsat8CountMultiband_2015');
Map.addLayer(landsat8CountMultiband.select('2016-01-01 to 2016-12-31'), {}, 'landsat8CountMultiband_2016');


// Get the mean and std
var landsat8CountMultiband_mean = landsat8CountMultiband.reduce('mean');
print(landsat8CountMultiband_mean, 'landsat8CountMultiband_mean');
Map.addLayer(landsat8CountMultiband_mean, {}, 'landsat8CountMultiband_mean');

var landsat8CountMultiband_std = landsat8CountMultiband.reduce('stdDev');
print(landsat8CountMultiband_std, 'landsat8CountMultiband_std');
Map.addLayer(landsat8CountMultiband_std, {}, 'landsat8CountMultiband_std');

// Export mean
Export.image.toDrive({  
  image: landsat8CountMultiband_mean,
  description: 'landsat8Count_2013to2016_mean',   
  region: Kalimantan,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

// Export std
Export.image.toDrive({  
  image: landsat8CountMultiband_std,
  description: 'landsat8Count_2013to2016_std',   
  region: Kalimantan,
  maxPixels: 1e12,
  scale: 30             // Important! 30 meter in this case of Landsat
});

