// Case study area for image stack export
var extent = ee.FeatureCollection("users/hadicu06/extent_DG_1"); 
Map.addLayer(extent, {}, 'extent');

var caseStudyArea = extent;                          // Change study area here!!!
Map.addLayer(caseStudyArea, {}, 'caseStudyArea');
Map.centerObject(caseStudyArea);


// Function to get scene id
var scene_ids = function(coll) {
    return coll.toList(coll.size(), 0).map(function(im) {
      // Get the image ID and strip off the first four chars '1_1_'
      // Untested other than this script 
      return ee.String(ee.Image(im).id());
    });
  };

// Import image collection
var sentinel1 = ee.ImageCollection('COPERNICUS/S1_GRD')
        .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VV'))
        .filter(ee.Filter.eq('resolution_meters', 10))   // Only 10m available, no 25 or 40
        .select(['VV'])
        .filterDate('2014-10-03', '2017-09-16')
        .filterBounds(caseStudyArea);
        
print(sentinel1, 'sentinel1');
        
//function removeLowEntropyValues(i) {
//  var entropy = i.multiply(10).int().entropy(ee.Kernel.square(3));
//  var lowEntropy = entropy.lt(0.05).focal_max(90, 'circle', 'meters', 3)
  
//  return i.updateMask(lowEntropy.not())
//}

//sentinel1 = sentinel1.map(removeLowEntropyValues)
        
var s1 = ee.Image(sentinel1.first());    

var palette = ['FFFFFF', 'E8E8E8', '696969', 'FFA54F', 'D2691E', 
               'F08080', 'EE2C2C',  'DC143C',
               'FFA500', 'FFD700', 'FFFF00', 'ADFF2F', '00CD00', '006400',
               '87CEFA', '1874CD', '0000CD', 'E066FF', 'BF3BFF', '9400D3'];

// Map.addLayer(s1.clip(caseStudyArea), {min:-30, max:-5, palette: palette}, 'S1 Field clip');
// Map.addLayer(s1, {min:-30, max:-5, palette: palette}, 'S1 Overview', false);

print(s1);

// Clip 
var sentinel1_clipped = sentinel1.map(function(img) {
  return(img.clip(caseStudyArea)) });
print(sentinel1_clipped, 'sentinel1_clipped');

Map.addLayer(sentinel1_clipped, {min:-30, max:-5, palette: palette}, 'S1 clipped');


// From image collection to multiband image, rename bands as image dates
var empty = ee.Image().select();
var sentinel1_clipped_multiband = sentinel1_clipped.iterate(function(image, result) {
  return ee.Image(result).addBands(image.select(['VV'], [ee.Date(image.get('system:time_start')).format('YYYY-MM-dd')]));    
    }, empty);                            

print(sentinel1_clipped_multiband, 'sentinel1_clipped_multiband');


// Export multiband (multidates) image
Export.image.toDrive({  // or toDrive
  image: sentinel1_clipped_multiband,
  description: 'Sentinel1VV_DG_1',   
  region: caseStudyArea,
  maxPixels: 1e12,
  scale: 10              // Important! product available in 10, 25, or 40m
});


// The exported TIF loses band names (= dates), so need to save the band names
var sceneId = scene_ids(sentinel1_clipped);
print(sceneId, "sceneIdSentinel1");
// Not yet figure out how to export the list to Drive, so just copy from console to excel for now 




//*********************************************************************
// View time series in console
//*********************************************************************

// Intact forest points in DG_1
var geometry = ee.FeatureCollection("users/hadicu06/intactForestPts_DG_1"); 
Map.addLayer(geometry, {}, 'intact forest points');
print(geometry, 'geometry');


// Create a time series chart.
var serie = ui.Chart.image.seriesByRegion(
    sentinel1, geometry, ee.Reducer.mean(), 'VV', 20, 'system:time_start', 'label')
        .setChartType('LineChart')
        .setOptions({
          title: 'Overview',
          vAxis: {title: 'dB'},
          lineWidth: 1,
          pointSize: 4,
          series: {
            0: {color: 'FF0000'}
             
}});


print(serie);
