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
      
      # remove local_tiles
      if('tiles' %in% resourcePaths()) removeResourcePath('tiles')

      # cleanup environment
      rv$sql <- 
        rv$mastergrid <- 
        rv$data_readme_url <- 
        rv$country <- 
        rv$version <- 
        rv$path <- NULL
      gc()
      
      # reset pointpoly
      updateRadioButtons(session=session, inputId='pointpoly', selected='Selected Point')
      
      # update version
      rv$country <- unlist(strsplit(input$data_select,' '))[1]
      rv$version <- unlist(strsplit(input$data_select,' '))[2]
      rv$path <- file.path(wopr_dir,rv$country,'population',rv$version)
      rv$data_readme_url <- file.path('https://wopr.worldpop.org/readme',
                                      basename(subset(catalogue_full,{
                                        country==rv$country & 
                                          category=='Population' & 
                                          version==rv$version & 
                                          filetype=='README'},
                                        select='url')[1,1]))
      rv$wopr_url <- paste0('https://wopr.worldpop.org/?',file.path(rv$country,'Population',rv$version))

      # local SQL mode
      if(version_info[input$data_select,'local_sql']){
        
        message(paste0('Using local SQL database for ',input$data_select,'.'))
        
        # connect to SQL database
        rv$sql <- RSQLite::dbConnect(RSQLite::SQLite(), 
                                     file.path(rv$path,
                                               paste0(rv$country,'_population_',gsub('.','_',as.character(rv$version), fixed=T),'_sql.sql')))
        
        # load mastergrid
        rv$mastergrid <- raster::raster(file.path(rv$path,
                                                  paste0(rv$country,'_population_',gsub('.','_',as.character(rv$version), fixed=T),'_mastergrid.tif')))
      }
      
      # local tiles
      if(version_info[input$data_select, 'local_tiles']){
        
        message(paste0('Using local image tiles for ',input$data_select,'.'))
        
        addResourcePath('tiles', file.path(rv$path, 
                                           paste0(rv$country,
                                                  '_population_',
                                                  gsub('.','_',as.character(rv$version),fixed=T),
                                                  '_tiles')))
      }
    })

    # map
    output$map <- leaflet::renderLeaflet( map(country=rv$country, 
                                              version=rv$version,
                                              local_tiles=version_info[input$data_select, 'local_tiles']) )

    # update map: marker with mouse clicks
    observeEvent(input$map_click, {
      mapProxyMarker(input$pointpoly, input$map_click, input$map_zoom)
    })
    
    # update map: point/polygon selection
    observe( mapProxyPoly(input$pointpoly) )
    
    # age-sex selection
    observe({
      rv$agesex_select <- agesexLookup(input$male,
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
      
      shinyjs::disable('submit')
      
      rv$N <- rv$agesexid <- NA
      
      if(class(rv$feature)[1]=='sf'){
        
        withProgress({
          if(version_info[input$data_select,'local_sql']){
            try({
              i <- getPopSql(cells=cellids(rv$feature, rv$mastergrid),
                             db=rv$sql,
                             agesex_select=rv$agesex_select,
                             agesex_table=agesex[[input$data_select]],
                             get_agesexid=T,
                             timeout=60)
              rv$N <- i[['N']]
              rv$agesexid <- i[['agesexid']]
            })
          } else {
            try({
              i <- getPop(feature=rv$feature,
                          country=rv$country,
                          version=rv$version,
                          agesex_select=rv$agesex_select,
                          key=input$key,
                          get_agesexid=T,
                          url=url,
                          timeout=60)
              rv$N <- i[['N']]
              rv$agesexid <- i[['agesexid']]
            })
          }
        }, message='woprizing:', 
        detail='Fetching population total for selected area and demographic group...', 
        value=0.5)
      }
      shinyjs::enable('submit')
    })
    
    # side plot
    output$sidePlot <- renderPlot({ 
      plotPanel(N=rv$N, 
                agesex_select=rv$agesex_select,
                agesex_table=agesex[[input$data_select]][rv$agesexid,], 
                confidence=input$ci_level, 
                tails=input$ci_type,
                popthresh=input$popthresh) 
      })
    
    # results table
    output$results_table <- renderTable( rv$table, digits=3, striped=T, format.args=list(big.mark=",", decimal.mark="."), rownames=T)

    # save button
    observeEvent(input$save_button, {
      
      if(!is.null(rv$N)){
        ct <- resultTable(input, rv)
        
        if(!'table' %in% names(rv)){
          rv$table <- ct
        } else {
          rv$table <- rbind(rv$table, ct)
        }
        row.names(rv$table) <- 1:nrow(rv$table)
        
        showNotification('Population estimate added to the "Saved" tab.', type='message')
        
      } else {
        showNotification('Need to submit a population query before results can be saved.', type='message')
      }
    })

    # download button
    output$download_table <- downloadHandler(filename = paste0('woprVision_',format(Sys.time(), "%Y%m%d%H%M"),'.csv'),
                                             content = function(file) write.csv(rv$table, file, row.names=TRUE))
    # clear button
    observeEvent(input$clear_button, {
      showModal(modalDialog('Are you sure you want to clear all saved population estimates?', 
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
    
    # WOPR url
    output$wopr_web <- renderText(
      return(paste('<iframe style="height: calc(98vh - 85px); width:100%" src="', rv$wopr_url, '", frameBorder="0"></iframe>', sep = ""))
    )

    # data readme
    output$data_readme <- renderText(
        return(paste('<iframe style="height: calc(98vh - 85px); width:100%" src="', rv$data_readme_url, '", frameBorder="0"></iframe>', sep = ""))
    )
})




