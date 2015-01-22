# test rig for leaflet app
# install it using:
# devtools::install_github("rstudio/leaflet")
#

library(shiny)
library(leaflet)
# library(raster)
source('./defs.R')

shinyServer(function(input, output, session) {
  
  
  map = leaflet()

  output$baseTxt <-renderText({
    sel<-gibsDT[Identifier==input$selLayer]
    return(paste(sel$Title,"Date Range: ",sel$dateRange))
    })
 
  output$olTxt <-renderTable({
    return(gibsDT[Identifier %in% input$selOverlay,list(Title,WGS84BoundingBox,zoomLevel,dateRange)])
  })
  
  output$mapPlot <- renderLeaflet({ 
    lastBounds <- isolate( input$mapPlot_bounds )
    zoomLvl <- isolate(glZoomlevel[which(gibsLayers == input$selLayer)])
    tileSet <- isolate(glTileset[which(gibsLayers == input$selLayer)])
    iType <- isolate(glImgtype[which(gibsLayers == input$selLayer)])
    
    # overlay selection data - needs to be modified to allow multiselect
    olzoomLvl <- isolate(oglZoomlevel[which(gibsOverlays %in% input$selOverlay)])
    oltileSet <- isolate(oglTileset[which(gibsOverlays %in%  input$selOverlay)])
    oliType <- isolate(oglImgtype[which(gibsOverlays %in%  input$selOverlay)])
    

    
    # add the base layer
    m <- map %>% addTiles(paste0('http://map1{s}.vis.earthdata.nasa.gov/wmts-webmerc/',input$selLayer,'/default/',input$selDate,'/',tileSet,'/{z}/{y}/{x}.',iType),
                         attribution = paste(
                           '<a href="https://earthdata.nasa.gov/gibs">NASA EOSDIS GIBS</a>'
                         ),
                         options = list(
                           maxZoom = zoomLvl,
                           minZoom = 1,
                           tileSize = 256,
                           subdomains = "abc",
                           noWrap = "true",
                           crs = "L.CRS.EPSG3857",    
                           continuousWorld = "true",
                           # Prevent Leaflet from retrieving non-existent tiles on the borders.
                           bounds = list(list(-85.0511287776, -179.999999975),list(85.0511287776, 179.999999975))
                         ))
    
    # add all the selected overlay layers
    for(i in 1:length(input$selOverlay) ){
      m <- m %>% addTiles(paste0('http://map1.vis.earthdata.nasa.gov/wmts-webmerc/',input$selOverlay[i],'/default/',input$selDate,'/',oltileSet[i],'/{z}/{y}/{x}.',oliType[i]),
                          attribution = paste('<a href="https://earthdata.nasa.gov/gibs">NASA EOSDIS GIBS</a>'),
                          options = list(
                            maxZoom = 9,
                            maxNativeZoom = olzoomLvl[i],
                            minZoom = 1,
                            tileSize = 256,
                            subdomains = "abc",
                            noWrap = "true",
                            crs = "L.CRS.EPSG3857",    
                            continuousWorld = "true",
                            opacity = 0.3,
                            # Prevent Leaflet from retrieving non-existent tiles on the borders.
                            bounds = list(list(-85.0511287776, -179.999999975),list(85.0511287776, 179.999999975))
                          ))
    }
    
    # set the extents - this could use some work
    if(!is.null(lastBounds$north)) m <- m %>% fitBounds(lastBounds$east,lastBounds$south,lastBounds$west,lastBounds$north)
    
    # polygon display disabled - shinyapps.io doesn't support rgdal?
#    m %>% addPolygons(data=shapefile(paste0('ll/',input$selPoly)))
    m
    
  })
  
  output$mapTxt <- renderText({return(paste(input$selDate,input$mapPlot_zoom,input$mapPlot_center,input$mapPlot_bounds$north,input$mapPlot_bounds$east,input$mapPlot_bounds$south,input$mapPlot_bounds$west))})
  
})
