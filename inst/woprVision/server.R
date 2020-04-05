shinyServer(
  function(input, output, session){
    
    # reactive values
    rv <- reactiveValues()
    
    ##-- observe new data selected --##
    observeEvent(input$data_select, {
      
      # disconnect from last database
      if(!is.null(rv$sql)) {
        DBI::dbDisconnect(rv$sql)
      }
      
      # cleanup environment
      rv$sql <- 
        rv$mastergrid <- 
        rv$data_readme_url <- 
        rv$country <- 
        rv$version <- 
        rv$path <- NULL
      gc()
      
      # remove local_tiles
      if('tiles' %in% resourcePaths()) removeResourcePath('tiles')

      # reset pointpoly
      updateRadioButtons(session=session, inputId='pointpoly', selected='Selected Point')
      
      # disable submit
      shinyjs::disable('submit')
      
      # update version
      rv$country <- unlist(strsplit(input$data_select,' '))[1]
      rv$version <- unlist(strsplit(input$data_select,' '))[2]
      rv$path <- file.path(wopr_dir,rv$country,'population',rv$version)
      
      # update urls
      rv$data_readme_url <- file.path('https://wopr.worldpop.org/readme',
                                      version_info[input$data_select,'readme'])
      rv$wopr_url <- paste0('https://wopr.worldpop.org/?',file.path(rv$country,'Population',rv$version))

      # local SQL mode
      if(version_info[input$data_select,'local_sql']){
        message(paste0('Using local SQL database for ',input$data_select,'.'))
        rv$sql <- RSQLite::dbConnect(RSQLite::SQLite(), 
                                     file.path(rv$path,
                                               paste0(rv$country,'_population_',gsub('.','_',as.character(rv$version), fixed=T),'_sql.sql')))
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
                                                  '_tiles')))}
      # local basemap
      if(dir.exists(file.path(wopr_dir,'basemap'))){
          addResourcePath('basemap', file.path(wopr_dir,'basemap'))
      }
    })

    ## leaflet map
    output$map <- leaflet::renderLeaflet({
      map(country=rv$country, version=rv$version, 
          local_tiles=version_info[input$data_select, 'local_tiles'],
          southern=country %in% c('ZMB')) 
    })

    ## change location selection tool
    observeEvent(input$pointpoly,{
      
      rv$N <- rv$agesexid <- NULL
      
      mapProxyPoly(input$pointpoly)
      
      if(input$pointpoly=='Upload File'){
        
        shinyjs::enable('user_json')
        
        if(is.null(input$user_json)){
          shinyjs::disable('submit')
        }
      } else {
        shinyjs::reset('user_json')
        shinyjs::disable('submit')
      }
    })
    
    ## age-sex selection
    observeEvent(c(input$male, input$female, input$male_select, input$female_select), {
      rv$N <- rv$agesexid <- NULL
      rv$agesex_select <- agesexLookup(input$male, input$female, input$male_select, input$female_select)
    })
    
    ## file upload
    observeEvent(input$user_json, {
      if(!is.null(input$user_json)){
        
        tryCatch({
          updateSelectInput(session, 'pointpoly', selected='Upload File')
          
          rv$feature <- sf::st_read(input$user_json[,'datapath'], quiet=T)
          rv$feature <- rv$feature[1:min(20,nrow(rv$feature)),1]
          rv$feature <- sf::st_transform(rv$feature, crs=4326)
          
          mapProxyFile(rv$feature)
          
        }, warning=function(w){
          shinyjs::reset('user_json')
          showNotification(as.character(w), type='warning', duration=20)
        }, error=function(e){
          shinyjs::reset('user_json')
          showNotification(as.character(e), type='error', duration=20)
        })
      }
    })
    
    ## map click
    observeEvent(input$map_click, {
      if(input$pointpoly=='Selected Point'){
        rv$N <- rv$agesexid <- NULL
        mapProxyMarker(input$map_click, input$map_zoom)
        rv$feature <- leaf_sf(input$map_click, input$pointpoly)
      }
    })
    
    ## draw polygon
    observeEvent(input$map_draw_all_features, {
      if(input$pointpoly=='Custom Area'){
        rv$N <- rv$agesexid <- NULL
        rv$feature <- leaf_sf(input$map_draw_all_features, input$pointpoly)
      }
    })
    
    # toggle submit button
    observeEvent(rv$feature, {
      if(is.null(rv$feature)){
        shinyjs::disable('submit')
      } else {
        shinyjs::enable('submit')
      }
    })
    
    # toggle save button
    observe({  
      if(is.null(rv$N) | input$pointpoly=='Upload File'){
        shinyjs::disable('save_button')
      } else {
        shinyjs::enable('save_button')
      }
    })
    
    ##-- query wopr --##
    observeEvent(input$submit, {
      
      shinyjs::disable('submit')
      
      rv$N <- rv$agesexid <- NA

      if(class(rv$feature)[1]=='sf'){
        
        withProgress({
          tryCatch({
            
            if(input$pointpoly=='Upload File'){

              # Upload File
              rv$feature <- woprize(feature=rv$feature, 
                                    country=rv$country, 
                                    version=rv$version, 
                                    agesex_select=rv$agesex_select,
                                    confidence=input$ci_level/1e2,
                                    tails=ifelse(input$ci_type=='Interval',2,1),
                                    abovethresh=input$popthresh,
                                    url=url,
                                    timeout=5*60)
              
              ct <- resultTable(input, rv)
              
              if(!'table' %in% names(rv)) { 
                rv$table <- ct
              } else { 
                rv$table <- rbind(ct, rv$table)}
              row.names(rv$table) <- 1:nrow(rv$table)
              
              showNotification(paste('Population estimates for',nrow(rv$feature),'features added to the "Saved" tab.'), type='message', duration=10)
              
              shinyjs::reset('user_json')
            } 
            
            if(input$pointpoly %in% c('Selected Point', 'Custom Area')) {
              if(version_info[input$data_select,'local_sql']){
                
                # query local SQL
                i <- getPopSql(cells=cellids(rv$feature, rv$mastergrid),
                               db=rv$sql,
                               agesex_select=rv$agesex_select,
                               agesex_table=agesex[[input$data_select]],
                               get_agesexid=T,
                               timeout=2*60)
                rv$N <- i[['N']]
                rv$agesexid <- as.character(i[['agesexid']])
                
              } else {
                
                # query wopr
                i <- getPop(feature=rv$feature,
                            country=rv$country,
                            version=rv$version,
                            agesex_select=rv$agesex_select,
                            get_agesexid=T,
                            url=url,
                            timeout=2*60)
                rv$N <- i[['N']]
                rv$agesexid <- as.character(i[['agesexid']])
              }
            }
          }, warning=function(w){
            showNotification(as.character(w), type='warning', duration=20)
          }, error=function(e){
            showNotification(as.character(e), type='error', duration=20)
          })
        }, message='woprizing:', 
        detail='Fetching population total for selected location(s) and demographic group(s)...', 
        value=0.5)
      }
      shinyjs::enable('submit')
    })
    
    ##-- create plot --##
    output$sidePlot <- renderPlot({ 
      plotPanel(N=rv$N, 
                agesex_select=rv$agesex_select,
                agesex_table=agesex[[input$data_select]][rv$agesexid,], 
                confidence=input$ci_level, 
                tails=input$ci_type,
                popthresh=input$popthresh) 
    })
    
    # save button
    observeEvent(input$save_button, {
      
      if(!is.null(rv$N) & !is.null(rv$feature)){
        ct <- resultTable(input, rv)
        
        if(!'table' %in% names(rv)){
          rv$table <- ct
        } else {
          rv$table <- rbind(ct, rv$table)
        }
        row.names(rv$table) <- 1:nrow(rv$table)
        
        showNotification('Population estimate added to the "Saved" tab.', type='message', duration=10)
      } else {
        showNotification('Need to submit a population query before results can be saved.', type='message')
      }
      shinyjs::reset('save_name')
    })
    
    ##-- saved tab --##
    
    # results table
    output$results_table <- renderTable( rv$table, digits=3, striped=T, format.args=list(big.mark=",", decimal.mark="."), rownames=F)

    # download button
    output$download_table <- downloadHandler(filename = paste0('woprVision_',format(Sys.time(), "%Y%m%d%H%M"),'.csv'),
                                             content = function(file) write.csv(rv$table, file, row.names=TRUE))
    # clear button
    observeEvent(input$clear_button, {
      showModal(modalDialog('Are you sure you want to clear all saved population estimates?', 
                            title='Confirm',
                            footer=tagList(modalButton('Cancel'),actionButton('clear','Clear Saved Estimates'))
                            ))
    })
    observeEvent(input$clear, {
      rv$table <- NULL
      removeModal()
    })

    ##-- tabs --##
    
    # wopr download tab
    output$wopr_web <- renderText(
      return(paste('<iframe style="height: calc(98vh - 85px); width:100%" src="', rv$wopr_url, '", frameBorder="0"></iframe>', sep = ""))
    )

    # readme tab
    output$data_readme <- renderText(
        return(paste('<iframe style="height: calc(98vh - 85px); width:100%" src="', rv$data_readme_url, '", frameBorder="0"></iframe>', sep = ""))
    )
})




