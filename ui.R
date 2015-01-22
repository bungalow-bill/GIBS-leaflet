
# Test rig for projected leaflet map using web mercator GIBS layers
#

library(shiny)
library(leaflet)
source('./defs.R')


shinyUI(fluidPage(
  
  # Application title
  titlePanel("GIBS Leaflet Test Page"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("selLayer","Available Image Layers",gibsLayers,selected=gibsLayers[1],width="100%"),
      selectInput("selOverlay","Available Overlays",gibsOverlays,selected=gibsOverlays[17],width="100%",multiple=TRUE,selectize=FALSE),
#      selectInput("selPoly","Polygon Locations",polyPolys,selected=polyPolys[18],width="100%"),
      dateInput("selDate",
                "Viewing Date",
                min = "1979-01-01",
                max = format(Sys.Date(), "%Y-%m-%d"),
                value = format(Sys.Date(), "%Y-%m-%d")),
      h4("Base Layer Details"),
      textOutput("baseTxt")

    ),
    
    # Show leaflet map with a text div reporting the selected date and extents 
    mainPanel(
      h4(verbatimTextOutput("mapTxt")),
      leafletOutput("mapPlot",height=600),
      h4("Overlay Details"),
      tableOutput("olTxt")
    )
  )
))
