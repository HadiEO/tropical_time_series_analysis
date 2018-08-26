# UI ----------------------------------------------------------------------

ui <- fluidPage(
  fluidRow(
    column(width = 3, wellPanel(
      h3("myBfastApp"),
      h4("Run bfastmonitor and bfast interactively"),
      tags$p(em("by ", a("Hadi", href = "https://people.aalto.fi/new/hadi.hadi"))),
      tags$p(em("based on works of ", 
                a("Loïc Dutrieux", href = "https://github.com/loicdtx?tab=repositories")))),
      h4("Upload input / download output"),
      tabsetPanel(
        tabPanel("Time series",
                 wellPanel(
                   fileInput(inputId = "tsData", label = "Upload time series (.rds)", multiple = FALSE, accept = ".rds"),
                   tags$p("Go through the time series from the first one"),
                   actionButton("nextTs", "Next time series"),
                   tags$h4(),
                   uiOutput("uiSelectTs"),
                   actionButton("selectTs", "Select time series"))),
        tabPanel("Images",
                 wellPanel(fileInput(inputId = "vhsrs", label = "Image files (.tif)", multiple = TRUE, accept = ".tif"),
                           fileInput(inputId = "colourMaps", label = "Colourmap files (.clr)", multiple = TRUE, accept = ".clr"),
                           textInput(inputId = "vhsrsDates", label = "Type the dates of VHSR (separated by ';')"),
                           fileInput(inputId = "samplePixels", label = "Pixels (polygons) selected for interpretation (zipped shp)", accept = ".zip"),
                           actionButton(inputId = "renderMap", label = "Render map"))),
        tabPanel("Download",
                 wellPanel(textInput(inputId = "downloadBfmTableName", label = "Name for Downloaded Bfm Table"),
                           downloadButton('downloadBfmTable', 'Download Bfm Table'),
                           tags$hr(),
                           textInput(inputId = "downloadBfTableName", label = "Name for Downloaded Bf Table"),
                           downloadButton('downloadBfTable', 'Download Bf Table')))
      )),
    column(width = 5,
           tags$h4("Toggle between time series plot and annotation table"),
           tabsetPanel(
             tabPanel("Time series plot",
                      wellPanel(plotOutput("bfmPlot", height = 200, click = "bfmPlotClick"),           # bfm plot
                                tableOutput("bfmPlotInfo"),
                                actionButton("bfmRegisterDate", "Register date"),
                                plotOutput("bfPlot", height = 200, click = "bfPlotClick"),             # bf plot
                                verbatimTextOutput("bfPlotInfo"),
                                actionButton("bfRegisterDate", "Register date"))),
             tabPanel("Interpretation table",
                      tableOutput("bfmTable"),
                      tableOutput("bfTable"))
           )
    ),
    column(width = 4,
           tags$h4("Interactive map"),
           wellPanel(leafletOutput("myMap"),
                     textOutput("pixelId"))
    )
  ),
  fluidRow(
    column(width = 3, offset = 3, 
           tags$h4("Bfm parameters"), 
           wellPanel()),
    column(width = 3,
           tags$h4("Bf parameters"), 
           wellPanel()),
    
    column(width = 3,                                         # debug output
           tags$h4("Debug output"),
           verbatimTextOutput("debugOutput"))
  )
)



server <- function(input, output) {

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
  })
  
  
  # Reactive to retrieve selected time series
  currentTs <- reactive({
    data <- tsDataProcessed()
    tsId <- as.character(rv$myDf$Id)    # just make sure Id is a character
    data <- data[[tsId]]
    # Convert to data frame so nearPoints() can work
    data <- tibble(date = time(data), value = data)
  })
  
  # Output tabPanel 1: time series plot   
  output$bfmPlot <- renderPlot({
    data <- currentTs()
    tsId <- as.character(rv$myDf$Id)
    # Plot time series (later change to bfm or bf plot)
    plot(data$date, data$value,                                   
         type = "p", pch = 19, xlab = "Date", ylab = "NDMI", 
         ylim = c(-0.3, 0.7), main = paste0("Pixel ID: ", tsId))
  })
  
  # Reactive to interact with time series plot using nearPoints(), to read date of data point
  tsClicked <- reactive({
    data <- currentTs()
    tsClicked <- nearPoints(data, input$bfmPlotClick,
                            xvar = "date", yvar = "value", maxpoints = 1)
  })
  
  # Output printing the time series Id of point clicked (nearPoints()) on time series plot
  output$bfmPlotInfo <- renderTable({
    tsClicked()
  })
  
  
}
  



shinyApp(ui, server)
