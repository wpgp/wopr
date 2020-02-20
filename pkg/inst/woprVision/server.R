shinyServer(
  function(input, output, session){
    
    # reactive values
    rv <- reactiveValues()
    
    # new data selected
    observeEvent(input$data_select, {
      
      # disconnect from last database
      if(!is.null(rv$sql)) {
        DBI::dbDisconnect(rv$sql)
      }
      
      # remove localTiles
      if('tiles_population' %in% resourcePaths()) removeResourcePath('tiles_population')

      # cleanup environment
      rv$sql <- 
        rv$mastergrid <- 
        rv$data_readme_url <- 
        rv$country <- 
        rv$version <- 
        rv$path <- NULL
      gc()
      
      # update version
      rv$country <- unlist(strsplit(input$data_select,' '))[1]
      rv$version <- unlist(strsplit(input$data_select,' '))[2]
      rv$path <- file.path(woprDir,rv$country,'population',rv$version)
      rv$data_readme_url <- file.path('https://wopr.worldpop.org/readme',
                                      basename(subset(catalogue_full,{
                                        country==rv$country & 
                                          category=='Population' & 
                                          version==rv$version & 
                                          filetype=='README'},
                                        select='url')[1,1]))

      # local SQL mode
      if(version_info[input$data_select,'localSql']){
        
        # connect to SQL database
        rv$sql <- RSQLite::dbConnect(RSQLite::SQLite(), 
                                     file.path(rv$path,
                                               paste0(rv$country,'_population_',gsub('.','_',as.character(rv$version), fixed=T),'_sql.sql')))
        
        # load mastergrid
        rv$mastergrid <- raster::raster(file.path(rv$path,
                                                  paste0(rv$country,'_population_',gsub('.','_',as.character(rv$version), fixed=T),'_mastergrid.tif')))
      }
      
      # local tiles
      if(version_info[input$data_select, 'localTiles']){
        addResourcePath('tiles_population',file.path(rv$path, 
                                                paste0(rv$country,
                                                       '_population_',
                                                       gsub('.','_',as.character(rv$version),fixed=T),
                                                       '_tiles_population')))
      }
    })

    # map
    output$map <- leaflet::renderLeaflet( map(country=rv$country, 
                                     version=rv$version,
                                     localTiles=version_info[input$data_select, 'localTiles']) )

    # update map: marker with mouse clicks
    observeEvent(input$map_click, {
      mapProxyMarker(input$pointpoly, input$map_click, input$map_zoom)
    })
    
    # update map: point/polygon selection
    observe( mapProxyPoly(input$pointpoly) )
    
    # age-sex selection
    observe({
      rv$agesexSelect <- agesexLookup(input$male,
                                      input$female,
                                      input$male_select,
                                      input$female_select
                                      )
      })
    
    # sf object
    observe({
      if(input$pointpoly=='Selected Point'){
        rv$feature <- leaf_sf(input$map_click, input$pointpoly)
      } else if(input$pointpoly=='Custom Area'){
        rv$feature <- leaf_sf(input$map_draw_all_features, input$pointpoly)
      }
    })
    
    # query wopr
    observeEvent(input$submit, {
      
      rv$N <- rv$agesexid <- NA
      
      if(class(rv$feature)[1]=='sf'){
        
        # shinyjs::disable('submit')
        
        withProgress({
          if(version_info[input$data_select,'localSql']){
            try({
              i <- getPopSql(cells=cellids(rv$feature, rv$mastergrid),
                             db=rv$sql,
                             agesexSelect=rv$agesexSelect,
                             agesexTable=agesex[[input$data_select]],
                             getAgesexId=T)
              rv$N <- i[['N']]
              rv$agesexid <- i[['agesexid']]
            })
          } else {
            try({
              i <- getPop(feature=rv$feature,
                          country=rv$country,
                          ver=rv$version,
                          agesex=rv$agesexSelect,
                          key=input$key,
                          getAgesexId=T,
                          url=url)
              rv$N <- i[['N']]
              rv$agesexid <- i[['agesexid']]
            })
          }
        }, message='woprizing:', 
        detail='Fetching population total for selected area and demographic group...', 
        value=0.5)
      }
    })
    
    # side plot
    output$sidePlot <- renderPlot({ 
      # shinyjs::enable('submit')
      plotPanel(N=rv$N, 
                agesexSelect=rv$agesexSelect,
                agesexTable=agesex[[input$data_select]][rv$agesexid,], 
                confidence=input$ci_level, 
                tails=input$ci_type,
                popthresh=input$popthresh) 
      })
    
    # results table
    output$results_table <- renderTable( rv$table, digits=3, striped=T, format.args=list(big.mark=",", decimal.mark="."), rownames=T)

    # save button
    observeEvent(input$save_button, {
      ct <- resultTable(input, rv)

      if(!'table' %in% names(rv)){
        rv$table <- ct
      } else {
        rv$table <- rbind(rv$table, ct)
      }
      row.names(rv$table) <- 1:nrow(rv$table)

      showNotification('Population estimate added to the "Saved Estimates" tab.', type='message')
    })

    # download button
    output$download_table <- downloadHandler(filename = paste0('woprVision_',format(Sys.time(), "%Y%m%d%H%M"),'.csv'),
                                             content = function(file) write.csv(rv$table, file, row.names=TRUE))
    # clear button
    observeEvent(input$clear_button, {
      showModal(modalDialog('Are you sure you want to clear all data from the "Saved Estimates" tab?', 
                            title='Confirm',
                            footer=tagList(modalButton('Cancel'),actionButton('clear','Clear Saved Estimates'))
                            ))})
    
    observeEvent(input$clear, {
      rv$table <- NULL
      removeModal()
    })

    # clear results with new user selection
    observeEvent(c(input$data_select, 
                   input$pointpoly,
                   input$male,
                   input$female,
                   input$male_select,
                   input$female_select), {
                     rv$N <- rv$agesexid <- NULL
                     gc()
                   })
    
    # data readme
    output$data_readme <- renderText({
      return(paste('<iframe style="height:600px; width:100%" src="', rv$data_readme_url, '"></iframe>', sep = ""))
    })
})




