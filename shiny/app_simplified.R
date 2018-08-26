# Run .Rprofile first
# # 
# library(shiny)
# library(dplyr)
# library(tidyverse)
# library(googleway)
# library(sp)
# library(leaflet)
# library(htmltools)
# library(htmlwidgets)
# library(plotwidgets)
# library(bfast)
# library(bfastSpatial)
# library(bfastPlot)
# library(lubridate)
# source("shiny/ggplotBfast.R")
# source("R/Rfunction/getSceneinfo_mod.R")
# library(scales)


# Todo: 
# - visualInfo doesn't update properly!
# - use req() for pre-condition checking
# - check code for shiny first-principles: https://rstudio-pubs-static.s3.amazonaws.com/192350_d3385f81117e4506a090da03ac8d3361.html
# - make polygon highlighted when clicked

# - add button "undisturbed_throughout"
# - delete record
# - if reach the last ts give warning, not gray out


# Revise ref dates
all.dating.adj <- read_rds(str_c(path, "/from_shiny/", "all_refChangeDate_final_adj_intactNoDate.rds"))
ref.date <- all.dating.adj %>% filter(Scene == "DG1")  # Which VHSR scene? <<<<<<<<<<<<<<<<<<




# UI ----------------------------------------------------------------------

# Choices of comments to-type:
# "to_remove", 

ui <- fluidPage(
  fluidRow(
    column(width = 3, 
           h4("Upload input / set algorithm / download output"), 
           tabsetPanel(
             tabPanel("Time series",
                      wellPanel(
                        fileInput(inputId = "tsData", label = "Upload time series (.rds)", multiple = FALSE, accept = ".rds"),
                        tags$p('Go through the time series. Always begin with "Select time series"!'),
                        actionButton("nextTs", "Next time series"),
                        tags$h4(),
                        uiOutput("uiSelectTs"),
                        actionButton("selectTs", "Select time series"))),
             tabPanel("Images",
                      wellPanel(fileInput(inputId = "vhsrs", label = "Image files (.tif)", multiple = TRUE, accept = ".tif"),
                                fileInput(inputId = "colourMaps", label = "Colourmap files (.clr)", multiple = TRUE, accept =".clr"),
                                textInput(inputId = "vhsrsDates", label = "Type the dates of VHSR (separated by ';')", 
                                          value = "yyyy-mm-dd;yyyy-mm-dd"),
                                fileInput(inputId = "samplePixels", label = "Pixels (polygons) selected for interpretation (zipped shp)", accept = ".zip"),
                                actionButton(inputId = "renderMap", label = "Render map"))),
             tabPanel("Download",
                      wellPanel(textInput(inputId = "downloadTsTableName", label = "Name for downloaded reference date table"),
                                downloadButton('downloadTsTable', 'Download ref. date table'))),
             tabPanel("Bfm param.",
                      wellPanel(dateInput("bfmStartMon", label = "Beginning of monitoring period", value = "2000-01-01"),   # can set min = '2001-01-01', max = '2014-01-01', value = '2008-01-01'
                                radioButtons("bfmBandwidth", label = "MOSUM bandwidth", 
                                             choices = c("0.25 (default)"="0.25", "0.5"="0.5", "1"="1"), selected = "0.25", inline = TRUE),
                                selectInput("bfmHistory", label = "History period",
                                            choices = list("ROC", "all"),
                                            selected = "all"),
                                checkboxInput("bfmHistoryNoiseRemoved", "History noise removal", value = FALSE),
                                checkboxInput("bfmAllNoiseRemoved", "Whole ts noise removal", value = FALSE),
                                checkboxInput("bfmBoundaryRMSE", "History RMSE as boundary", value = FALSE),
                                sliderInput("bfmFactorRMSE", "Factor multiplied with history RMSE", min = 1, max = 6, step = 0.5, value = 3),
                                sliderInput("bfmCons", "No. of consecutive breakpoints", min = 1, max = 6, step = 1, value = 1),
                                sliderInput("bfmMaxTimeSpan", "Max. no. of years span over breakpoints", min = 0, max = 3, step = 0.25, value = 2),
                                checkboxInput("bfmUpdateMOSUM", "MOSUM re-computed if false alarm", value = TRUE)
                                ))
                    )),
    column(width = 5,
           tags$h4("Toggle between time series plot and annotation table"),
           tabsetPanel(
             tabPanel("Processed time series",
                      wellPanel(tags$p("bfastmonitor"),
                                plotOutput("bfmPlot", height = 300, click = "bfmPlotClick"),           # bfm plot
                                textOutput("bfmPlotInfo"))),
             tabPanel("Time series", 
                      wellPanel(plotOutput("tsPlot", height = 300, click = "tsPlotClick"),
                                tableOutput("tsPlotInfo"),
                                actionButton("tsIdToRemove", "To remove"),
                                textInput("comment", label = "Comment", value = "NA"),
                                actionButton("tsRegisterDate", "Register"))),
             tabPanel("Reference date table", tableOutput("tsTable"))
           )
    ),
    column(width = 4,
           tags$h4("Interactive map"),
           wellPanel(leafletOutput("myMap"),
                     textOutput("pixelInfo"),
                     actionButton("resetMyMap", "Reset map")),
           wellPanel(tags$p("Wait for message: "), textOutput("myMapReady")),
           h4(),
           wellPanel(
             h3("myBfastApp"),     # h3
             tags$h4("Run bfastmonitor and bfast interactively"),   # h4
             tags$p(em("by ", a("Hadi", href = "https://people.aalto.fi/new/hadi.hadi"),
                       "based on works of ", a("Loïc Dutrieux", href = "https://github.com/loicdtx?tab=repositories"))),
             tags$p('To use the app: 
                  Fill input "Time series" and "Images", click "Render map" and wait until map is rendered and ready. 
                    Make sure the "Id" shown in the time series plots and the pixel "Id" shown on the map is the same.')
             )
    )
    )
)



# Server ------------------------------------------------------------------

server <- function(input, output) {
  
  # Part 1: time series ---------------------------------------------------
  
  # Reactive that read & process uploaded time series
  tsDataProcessed <- reactive({
    data <- input$tsData
    if (is.null(data))
      return(NULL)
    data <- read_rds(data$datapath)
    # Regularize the time series
    data <- as.list(data)
    data <- lapply(data, FUN = function(z) bfast::bfastts(z, dates = time(z), type = "irregular"))
  })
  
  # Dynamic UI to list time series ID
  output$uiSelectTs <- renderUI({
    data <- tsDataProcessed()
    selectInput("selectedTs",
                label = "Time series ID = pixel ID:",
                choices = as.list(names(data)))
  })
  
  # Reactive value to store Id of current time series / sample pixel (polygon)
  # "Id" will be updated as triggered by: 
  # (1) Button "Next time series"; (2) Button "Select time series"; and (3) Pixel (polygon) selected on map widget
  rv <- reactiveValues()
  rv$myDf <- NULL                  # create empty data frame "myDf" to store variables as columns
  
  # Counter values for button "Next time series"
  counter <- reactiveValues(i = 1)
  # Observer to increase counter values when button "Next time series" is clicked
  observe({
    if(input$nextTs > 0){
      counter$i <- isolate(counter$i) + 1
    }
  })
  
  # Observer to assign time series "Id" reacting to "Next time series" button
  # Initially "Id" is first time series
  observe({
    data <- tsDataProcessed()
    if(input$nextTs > 0){                            # Same conditional as above
      rv$myDf$Id <- tibble(Id = names(data)[counter$i]) # Id is created here cause the initial state is first time series Id, not NULL.
    }
  })
  
  # Observer to assign time series "Id" reacting to "Select time series" button
  observeEvent(input$selectTs, {
    rv$myDf$Id <- input$selectedTs
    # Set counter to the order of selected time series
    data <- tsDataProcessed()
    counter$i <- which(names(data) == rv$myDf$Id)
  })
  
  
  # Reactive to retrieve selected time series
  currentTs <- reactive({
    data <- tsDataProcessed()
    tsId <- as.character(rv$myDf$Id)    # just make sure Id is a character
    data <- data[[tsId]]
  })
  
  # Output tabPanel 2: raw time series plot   
  output$tsPlot <- renderPlot({                                    
    data <- input$tsData                  # Here we use "raw" i.e. irregular ts data
    if (is.null(data))
      return(NULL)
    data <- read_rds(data$datapath)
    
    # Scene name is actually stored in zoo ts object in dimnames(x)[[1]]
    scenesName <- dimnames(data)[[1]]
    sensorInfo <- getSceneinfo_mod(scenesName)$sensor
    
    # Selected time series Id
    tsId <- as.character(rv$myDf$Id)    # just make sure Id is a character
    data <- data[, tsId]
    
    # Convert to data frame so nearPoints() can work               
    df <- tibble(date = time(data), value = data, sensor = sensorInfo)
    
    # Plot time series 
    # plot(df$date, df$value,
    #      type = "p", pch = 19, xlab = "Date", ylab = "NDMI",
    #      ylim = c(-0.3, 0.7), main = paste0("Pixel ID: ", tsId))
    ggplot(df, aes(x = date, y = value, col = sensor)) +        # Here add col = sensor
      geom_point(na.rm = TRUE) +
      theme_bw() + labs(y = "NDMI", x = "Date", title = str_c("Id: ", tsId)) + scale_y_continuous(limits = c(-0.2, 0.6)) +
      scale_x_date(breaks = date_breaks("1 year"), labels = date_format("%Y")) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = c(0.1, 0.2))
  })
  
  
  # Reactive to run nearPoints() on raw time series plot
  tsPlotClicked <- reactive({
    data <- input$tsData                  # Here we use "raw" i.e. irregular ts data
    if (is.null(data))
      return(NULL)
    data <- read_rds(data$datapath)
    
    # Scene name is actually stored in zoo ts object in dimnames(x)[[1]]
    scenesName <- dimnames(data)[[1]]
    sensorInfo <- getSceneinfo_mod(scenesName)$sensor
    
    # Selected time series Id
    tsId <- as.character(rv$myDf$Id)    # just make sure Id is a character
    data <- data[, tsId]
    
    # Convert to data frame so nearPoints() can work               
    df <- tibble(date = time(data), value = data, sensor = sensorInfo)
    
    # Near points
    x <- nearPoints(df, input$tsPlotClick, maxpoints = 1)
    
    x$date <- as.character(x$date, origin="1970-01-01")
    
    # Show the table
    x
  })
  
  
  # Output printing the time series Id of point clicked (nearPoints()) on time series plot
  output$tsPlotInfo <- renderTable({
    tsPlotClicked()
  })
  
  
  # Output tabPanel 1: modified bfm plot ---------------------------------------------
  
  # Update: need original date to snap bfm date if slightly mismatch
  getOriginalDateNoNA <- reactive({
      data <- input$tsData                  # Here we use "raw" i.e. irregular ts data
      if (is.null(data))
        return(NULL)
      data <- read_rds(data$datapath)
      
      # Selected time series Id
      tsId <- as.character(rv$myDf$Id)    # just make sure Id is a character
      data <- data[, tsId]
      
      # Get original non-NA obs date
      originalDateNoNA <- index(data[!is.na(data)])
  })
  
  
  output$bfmPlot <- renderPlot({
    # The selected time series
    data <- currentTs()                    # This is a zoo ts object
    tsId <- as.character(rv$myDf$Id)
    
    bfmOutput <- bfastmonitor_mod(data, 
                                  start = lubridate::decimal_date(input$bfmStartMon), 
                                  formula = response ~ trend,
                                  plot = FALSE, 
                                  h = as.numeric(input$bfmBandwidth), 
                                  history = input$bfmHistory,
                                  historyNoiseRemoved = input$bfmHistoryNoiseRemoved,
                                  allNoiseRemoved = input$bfmAllNoiseRemoved,
                                  cons = input$bfmCons, 
                                  maxTimeSpan = input$bfmMaxTimeSpan,
                                  updateMOSUM = input$bfmUpdateMOSUM,
                                  boundaryRMSE = input$bfmBoundaryRMSE,
                                  factorRMSE = input$bfmFactorRMSE,
                                  originalDateNoNA = getOriginalDateNoNA())
    
                                 # later add the fun arguments "factorRMSE_immediate" and "allowImmediateConfirm"

    # Don't do list(bfmOutput)
    bfmOutputPlot <- bfmPlot_mod(bfmOutput, plotlabs = c(tsId),
                         ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                         circleVersion = TRUE,
                         refDate = ref.date %>% filter(Id == tsId) %>% .[["Date_adj"]],     # NEW: show ref. date
                         displayRefDate = TRUE) +                                           # NEW: show ref. date
      theme_bw() + labs(y = "NDMI", x = "Date") + scale_y_continuous(limits = c(-0.2, 0.6)) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    

    bfmOutputPlot
  })
 
  
  # !! nearPoints() above doesn't seem to work with bfmPlot(), so just use normal "click" interaction
  output$bfmPlotInfo <- renderText({
    # Define function
    xy_str <- function(e) {
      if(is.null(e)) return("Click on a point to read values\n")
      paste0("Date = ", round(e$x, 3), " ; NDMI = ", round(e$y, 3), "\n")   # change x = Date, y = NDMI
    }
    paste0("click: ", xy_str(input$bfmPlotClick))
  })
  
  
  # Output tabPanel 2: time series interpretation table
  
  # (a) raw ts table  ----------------------------------------------------------
  
  # Create table to be filled, and downloaded
  
  rvTsTable <- reactiveValues()
  rvTsTable$myDf <- tibble(Id = character(0), Date = numeric(0), Comment = NA) # Disturbance date
  # Observer reacting to button "Register date" for bfmPlot
  observeEvent(input$tsRegisterDate, {
    tsId <- as.character(rv$myDf$Id)
    newRow <- tibble(Id = tsId, Date = tsPlotClicked()$date, Comment = input$comment)
    isolate(rvTsTable$myDf <- rbind(rvTsTable$myDf, newRow))
  })
  
  
  # Add row to indicate ID to remove when "tsIdToRemove" is pressed
  observeEvent(input$tsIdToRemove, {
    tsId <- as.character(rv$myDf$Id)
    newRow <- tibble(Id = tsId, Date = NA, Comment = "to_remove")
    isolate(rvTsTable$myDf <- rbind(rvTsTable$myDf, newRow))
  }) 
  
  
  # Display the time series interpretation table in tabPanel 2
  output$tsTable <- renderTable({
    rvTsTable$myDf
  })
  
  # Action button to download table
  output$downloadTsTable <- downloadHandler(
    filename = function() {
      paste(input$downloadTsTableName, ".rds", sep = "")
    },
    content = function(file) {
      write_rds(rvTsTable$myDf, file)
    }
  )
  
  
  

  # Part 2: map -------------------------------------------------------------
  
  # Read and process the input VHSRs
  prep_vhsr <- reactive({
    if (is.null(input$vhsrs)) return(NULL)
    vhsr <- list()
    for(i in 1:nrow(input$vhsrs)) {
      vhsr[[i]] <- raster(input$vhsrs[[i, "datapath"]])
    }
    return(vhsr)
  })
  
  # Read and process the input colourmaps 
  prep_clr <- reactive({
    if (is.null(input$colourMaps)) return(NULL)
    clr <- list()
    for(i in 1:nrow(input$colourMaps)) {
      clr[[i]] <- read_delim(input$colourMaps[[i, "datapath"]],
                             delim = " ", col_names = c("bitValue", "R", "G", "B"))
    }
    return(clr)
  })
  
  # Convert colourmaps to pallette
  prep_pal <- reactive({
    if (is.null(input$colourMaps)) return(NULL)
    pal <- list()
    for(i in 1:nrow(input$colourMaps)) {
      pal[[i]] <- prep_clr()[[i]] %>% dplyr::select(-bitValue) %>% t() %>%
        plotwidgets::rgb2col()
    }
    return(pal)
  })
  
  # Read and process the dates string (textInput)
  prep_date <- reactive({
    if (is.null(input$vhsrsDates))   return(NULL)
    date <- str_split(input$vhsrsDates, ";")
    date <- as.list(unlist(date))
    return(date)
  })
  
  # Read and process sample pixels (polygons)
  prep_pixels <- reactive({
    if (is.null(input$samplePixels$datapath))   return(NULL)
    # Function to get layer name from dsn (file path) in readOGR() arguments
    layerFromDsn <- function(x) {
      temp <- str_split(x, "/")
      temp <- as.list(unlist(temp))
      temp <- temp[[length(temp)]]
      out <- str_split(temp, "\\.")[[1]][1]
      return(out)
    }
    # Unzip the uploaded zipped shp files
    unzipped <- unzip(input$samplePixels$datapath)
    # ****************************************************************
    shp <- unzipped[3] # unzipped[5]; Need to figure out how to automatically select the .shp file # *********
    # ****************************************************************
    pixels <- readOGR(dsn = shp,
                      layer = layerFromDsn(shp))
    # Transform to lat-lon coordinate system
    pixelsUnproj <- spTransform(pixels, CRS("+init=epsg:4326")) # Attributes are "Id" and "Visual"
    return(pixelsUnproj)
  })
  
  # Store prep_pixels as reactive values
  # prep_pixels_out <- reactiveValues()
  # prep_pixels_out$myDf <- prep_pixels()
  
  
  # Make map ----------------------------------------------------------------
  
  # Make map when button "Render map" is clicked once all map input data are uploaded
  observeEvent(input$renderMap, {     
    output$myMap <- renderLeaflet({
      # Initialize map widget
      leafletOutput <- leaflet() %>%
        # Base groups
        addTiles(group = "Open Street Map") %>%
        addProviderTiles(providers$Esri.WorldImagery, options = providerTileOptions(noWrap = TRUE), 
                         group = "ESRI World Imagery")
      # Loop to add the multiple VHSR images
      prep_vhsr_out <- prep_vhsr()
      prep_pal_out <- prep_pal() 
      prep_date_out <- prep_date()
      for (i in 1:length(prep_vhsr_out)) {
        leafletOutput <- addRasterImage(leafletOutput,
                                        x = prep_vhsr_out[[i]],
                                        colors = prep_pal_out[[i]],
                                        group = prep_date_out[[i]],
                                        maxBytes = Inf)
      }
      
      # Add polygon (sample pixels)
      prep_pixels_out <- prep_pixels()                                  # change prep_pixels to reactiveValues
      # prep_pixels_out <- prep_pixels_out$myDf
      leafletOutput <- leafletOutput %>%
        addPolygons(data = prep_pixels_out, layerId = ~Id,
                    color = "#edf8b1", weight = 1, smoothFactor = 0.5,
                    opacity = 1.0, fillOpacity = 0,
                    fillColor = "null",
                    # highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE),
                    group = "Sample pixels")
      
      # Add layer controls, need to loop to specify group names.
      # For now, implement conditionals if there are 3, 4, or 5 vhsr images
      if (length(prep_vhsr_out) == 3) {
        leafletOutput <- addLayersControl(leafletOutput,
                                          baseGroups = c("Open Street Map", "ESRI World Imagery"),
                                          overlayGroups = c(prep_date_out[[1]], prep_date_out[[2]], prep_date_out[[3]], "Sample pixels"),                     # "Digital Globe"
                                          options = layersControlOptions(collapsed = FALSE))
      } else if(length(prep_vhsr_out) == 4) {
        leafletOutput <- addLayersControl(leafletOutput,
                                          baseGroups = c("Open Street Map", "ESRI World Imagery"),
                                          overlayGroups = c(prep_date_out[[1]], prep_date_out[[2]], prep_date_out[[3]], prep_date_out[[4]], "Sample pixels"),                     # "Digital Globe"
                                          options = layersControlOptions(collapsed = FALSE))
      } else if(length(prep_vhsr_out) == 5) {
        leafletOutput <- addLayersControl(leafletOutput,
                                          baseGroups = c("Open Street Map", "ESRI World Imagery"),
                                          overlayGroups = c(prep_date_out[[1]], prep_date_out[[2]], prep_date_out[[3]], prep_date_out[[4]], prep_date_out[[5]], "Sample pixels"),                     # "Digital Globe"
                                          options = layersControlOptions(collapsed = FALSE))
      } else {
        stop("Number of VHSR images should be either 3, 4, or 5 images")
      }
      
      # Finally display the map
      leafletOutput
    })
    output$myMapReady <- renderText({
      "Hey handsome/pretty, map and app is ready! :-)"
    })
  })
  
  
  # Zoom in sample pixel selected with (a) "Next time series" button; and (b) "Select time series" button
  # For this, we need the center coordinates of the sample pixels
  getPixelsCenters <- reactive({
    data <- prep_pixels() # This returns pixelsUnproj         # changed prep_pixels to reactiveValues
    # data <- prep_pixels_out$myDf
    pixelsCenters <- tibble(id = as.character(data$Id),
                            lon = coordinates(data)[,1],
                            lat = coordinates(data)[,2])
  })
  
  
  # Store as reactive values
  # getPixelsCentersOut <- reactiveValues()
  # getPixelsCentersOut$myDf <- getPixelsCenters()
  
  # Zoom in pixel following (a) "Next time series" button
  observeEvent(input$nextTs, {
    data <- prep_pixels()                               # changed prep_pixels to reactiveValues
    # data <- prep_pixels_out$myDf
    
    rv$myDf$Id <- tibble(Id = names(tsDataProcessed())[counter$i]) 
    
    x <- as.character(rv$myDf$Id)
    
    pixelsCenters <- getPixelsCenters()
    # pixelsCenters <- getPixelsCentersOut$myDf           # changed pixelsCenters to reactiveValues 
    selectedCenter <- pixelsCenters %>% dplyr::filter(id == x)
    selectedPixel <- data[data$Id == x,]
    
    # Write pixel info (this maybe not needed here)
    # visualInfo <- as.character(selectedPixel$Visual)
    # output$pixelInfo <- renderText({
    #   paste0("Sample pixel Id: ", rv$myDf$Id, ". Visual: ", visualInfo, ".")
    # })
    
    # The map
    updatedMap <- leafletProxy("myMap") %>% 
      setView(lat = selectedCenter$lat, 
              lng = selectedCenter$lon,
              zoom = 18)   %>%                      
      clearShapes() %>%                                    # Clear all shapes
      addPolygons(data = selectedPixel, layerId = ~Id,
                  color = "#edf8b1", weight = 1, smoothFactor = 0.5,    # color = "#444444"
                  opacity = 1.0, fillOpacity = 0, 
                  fillColor = "null"
                  # highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE)
      )
    updatedMap
  })
  
  # Zoom in pixel following (b) "Select time series" button
  observeEvent(input$selectTs, {
    data <- prep_pixels()                             # Changed prep_pixels to reactiveValues
    # data <- prep_pixels_out$myDf
    x <- as.character(rv$myDf$Id)
    # updateMapView()  
    pixelsCenters <- getPixelsCenters()
    # pixelsCenters <- getPixelsCentersOut$myDf         # changed pixelsCenters to reactiveValues
    selectedCenter <- pixelsCenters %>% dplyr::filter(id == x)
    selectedPixel <- data[data$Id == x,]
    
    # Write pixel info (this may be not needed)
    # visualInfo <- as.character(selectedPixel$Visual)
    # output$pixelInfo <- renderText({
    #   paste0("Sample pixel Id: ", rv$myDf$Id, ". Visual: ", visualInfo, ".")
    # })
    
    # The map
    updatedMap <- leafletProxy("myMap") %>% 
      setView(lat = selectedCenter$lat, 
              lng = selectedCenter$lon,
              zoom = 18)   %>%                      
      clearShapes() %>%                                    # Clear all shapes
      addPolygons(data = selectedPixel, layerId = ~Id,
                  color = "#edf8b1", weight = 1, smoothFactor = 0.5,    # color = "#444444"
                  opacity = 1.0, fillOpacity = 0, 
                  fillColor = "null"
                  # highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE)
      )
    updatedMap
  })
  
  # Map interaction: retrieve pixel/polygon Id = time series Id by clicking the polygon on the map widget
  # Reactive to shape click on the map,
  observeEvent(input$myMap_shape_click, {
    event <- input$myMap_shape_click
    # Update the reactive value "Id" 
    rv$myDf$Id  <- as.character(event$id)   # lat = event$lat, lon = event$lng
    
    # Set counter to the order of selected time series
    data <- tsDataProcessed()
    counter$i <- which(names(data) == rv$myDf$Id)
    
    # Get visual info from the polygon
    data <- prep_pixels()                             # Changed prep_pixels to reactiveValues
    # data <- prep_pixels_out$myDf
    selectedPixel <- data[data$Id == rv$myDf$Id,]
    visualInfo <- as.character(selectedPixel$Visual)
    
    # Write pixel info (this needs to be put outside!)
    output$pixelInfo <- renderText({
      paste0("Sample pixel Id: ", rv$myDf$Id, ". Visual: ", visualInfo, ".")
    })
    
  })
  
  
  
  
  # Observer to reset map on "Reset map" button click
  
  observeEvent(input$resetMyMap, {
    prep_pixels_out <- prep_pixels()                    # Changed prep_pixels to reactiveValues
    # prep_pixels_out <- prep_pixels_out$myDf
    leafletProxy("myMap") %>% 
      clearShapes() %>%                                    # Clear all shapes
      addPolygons(data = prep_pixels_out, layerId = ~Id,
                  color = "#edf8b1", weight = 1, smoothFactor = 0.5,
                  opacity = 1.0, fillOpacity = 0,
                  fillColor = "null",
                  # highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE),
                  group = "Sample pixels")
  })
  
  
  
} # End of server()


# shinyApp ----------------------------------------------------------------

shinyApp(ui = ui, server = server)









