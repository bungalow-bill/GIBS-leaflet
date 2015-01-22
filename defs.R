# definitions for GIBS WMTS tile layers
library(XML)
library(data.table)
# read in the list of available layers for the GIBS resource
# returns a data.table with useful parameters
# hardwire the location of the capabilities file
gibsRes<-"http://map1.vis.earthdata.nasa.gov/wmts-webmerc/1.0.0/WMTSCapabilities.xml"

# we are only interested in the <Layer> sections
doc<-xmlParse(gibsRes)
nodes<-getNodeSet(doc,"/r:Capabilities/r:Contents/r:Layer",c(r="http://www.opengis.net/wmts/1.0"))

gibsDF<-xmlToDataFrame(doc,nodes=nodes)

# the resulting data.frame needs some cleanup <- better XFile code above would be cool
# in the meantime just parse out the strings
gibsDF$Format<-gsub("image/","",gibsDF$Format)

# switch to data.table for better syntax
gibsDT<-as.data.table(gibsDF)
gibsDT[,zoomLevel:=as.numeric(substring(TileMatrixSetLink,nchar(TileMatrixSetLink)))]
gibsDT[,startDate:=as.POSIXct(strptime(substring(Dimension,27,36),"%Y-%m-%d"))]
gibsDT[,endDate:=as.POSIXct(strptime(substring(Dimension,38,47),"%Y-%m-%d"))]
gibsDT[,dateFreq:=substring(Dimension,49)]
gibsDT[,dateRange:=gsub("/","  ",substring(Dimension,27))]

# there are a few other fields that might need to be decoded, and the <Metadata> and <ResourceURL> tags could be picked up
# but the munging done so far is enough to access the data with leaflet
gibsLayers <- gibsDT[Format=='jpeg',Identifier]
glZoomlevel <- gibsDT[Format=='jpeg',zoomLevel]
glTileset <- gibsDT[Format=='jpeg',TileMatrixSetLink]
glImgtype <- gibsDT[Format=='jpeg',Format]

# I dont see any explicit metadata for if a layer is intended to be an overlay
# other than the file type, so we will use all png files as overlays
gibsOverlays <- gibsDT[Format=='png',Identifier]
oglZoomlevel<- gibsDT[Format=='png',zoomLevel]
oglTileset <- gibsDT[Format=='png',TileMatrixSetLink]
oglImgtype <- gibsDT[Format=='png',Format]

# get a list of any available shapefiles in the ll directory (pro-tip ll means lat/long)
polyPolys<-Sys.glob("ll/*.shp")
polyPolys<-gsub("ll/","",polyPolys)
