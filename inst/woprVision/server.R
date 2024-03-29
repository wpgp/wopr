shinyServer(
  function(input, output, session){
    
    # reactive values
    rv <- reactiveValues()
    
    # input dataset from url
    observe({
      query <- parseQueryString(session$clientData$url_search)
      
      if (!is.null(query[['data']])) {
        query[['data']] <- gsub('v', ' v', query[['data']])
        
        if(query[['data']] %in% row.names(version_info)){
          updateSelectInput(session, 
                            "data_select",
                            selected = query[['data']]
          )
        }
      }  
      
      if (!is.null(query[['lang']])) {
        if(query[['lang']] %in% languages){
          updateSelectInput(session, 
                            "lang_select",
                            selected = query[['lang']]
          )
        }
      }  
    })
    
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
        rv$path <-
        rv$N <-
        rv$agesexid <-
        rv$agesex_table <-  
        rv$agesex_choices <- NULL
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
      
      
      
      # update urls
      rv$data_readme_url <- file.path('https://wopr.worldpop.org/readme',
                                      version_info[input$data_select,'readme'])
      
      rv$wopr_url <- version_info[input$data_select, 'url'] 
      
      
      # deactivation message
      if(version_info[input$data_select,'deprecated']){
        showModal(modalDialog(HTML(paste0(input$data_select,rv$dict[["lg_annoyingmessage"]], '<a href="',rv$wopr_url,'" target="blank">',rv$wopr_url,'</a>')),
                              title=rv$dict[["lg_annoyingmessage_title"]],
                              footer=tagList(modalButton(rv$dict[["lg_thks"]]))))
      }
      
      # review message
      if(version_info[input$data_select,'under_review']){
        showModal(modalDialog(HTML(paste0(input$data_select,rv$dict[["lg_reviewmessage"]], '<a href="',rv$wopr_url,'" target="blank">',rv$wopr_url,'</a>')),
                              title=rv$dict[["lg_reviewmessage_title"]],
                              footer=tagList(modalButton(rv$dict[["lg_thks"]]))))
      }
      
      # local SQL mode
      if(version_info[input$data_select,'local_sql']){
        
        showNotification(paste(rv$dict[["lg_localSQL"]], input$data_select), type='message') # message(paste0('Using local SQL database for ',input$data_select,'.')) 
        
        rv$sql <- RSQLite::dbConnect(RSQLite::SQLite(),
                                     version_info[input$data_select, 'local_sql_path'])
        
        rv$mastergrid <- raster::raster(version_info[input$data_select, 'local_mastergrid_path'])
      }
      
      # local tiles
      if(version_info[input$data_select, 'local_tiles']){
        
        showNotification(paste(rv$dict[["lg_localtiles"]], input$data_select), type='message') # message(paste0('Using local image tiles for ',input$data_select,'.')) 
        
        addResourcePath('tiles', version_info[input$data_select, 'local_tiles_path'])
      }
      
      # age sex table
      if(version_info[input$data_select, 'local_agesex_table']){
        
        showNotification(paste(rv$dict[["lg_localagesex"]], input$data_select), type='message') # message(paste0('Using local image tiles for ',input$data_select,'.')) 
        
        rv$agesex_table <- getAgeSexTable(rv$country, rv$version, version_info[input$data_select, 'local_agesex_table_path'])

        
      } else {
        
        rv$agesex_table <- getAgeSexTable(rv$country, rv$version, locator=url)
        
        
      }
      
      # update agesex choices
      rv$agesex_choices <- getAgeSexNames(rv$agesex_table)
      
      shinyWidgets::updateSliderTextInput(session, 'female_select',
                                          choices = rv$agesex_choices,
                                          selected = c(rv$agesex_choices[1], rv$agesex_choices[length(rv$agesex_choices)]))
      shinyWidgets::updateSliderTextInput(session, 'male_select',
                                          choices = rv$agesex_choices,
                                          selected = c(rv$agesex_choices[1], rv$agesex_choices[length(rv$agesex_choices)]))
      # local basemap
      if(dir.exists(file.path(wopr_dir,'basemap'))){
        addResourcePath('basemap', file.path(wopr_dir,'basemap'))
      }
    })
    
    ## leaflet map
    output$map <- leaflet::renderLeaflet({
      map(country = rv$country,
          version = rv$version,
          dict = rv$dict,
          token= rv$token)
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
      rv$agesex_select <- agesexLookup(input$male, input$female, input$male_select, input$female_select, rv$agesex_choices, rv$agesex_table)
    })
    
    ## file upload
    observeEvent(input$user_json, {
      geojson_limit <- 45
      
      if(!is.null(input$user_json)){
        
        tryCatch({
          updateSelectInput(session, 'pointpoly', selected='Upload File')
          
          rv$feature <- sf::st_read(input$user_json[,'datapath'], quiet=T)
          
          if(nrow(rv$feature) > geojson_limit){
            rv$feature <- rv$feature[1:min(geojson_limit, nrow(rv$feature)),]
            showNotification(paste(rv$dict[["lg_gjson_limit1"]],geojson_limit,rv$dict[["lg_gjson_limit2"]]), type='warning', duration=10)
          }
          
          # rv$feature <- rv$feature[,1]
          
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
        updateCheckboxInput(session, 'toggle_plots', value=F)
      } else {
        shinyjs::enable('save_button')
        updateCheckboxInput(session, 'toggle_plots', value=T)
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
              feature <- woprize(feature=rv$feature,
                                 country=rv$country,
                                 version=rv$version,
                                 agesex_select=rv$agesex_select,
                                 confidence=input$ci_level/1e2,
                                 tails=ifelse(input$ci_type=='Interval',2,1),
                                 abovethresh=input$popthresh,
                                 url=url)
              
              # get settings for woprized features
              ct <- resultTable(input, rv)
              
              # keep only settings (remove results)
              ct <- ct[,c('data','female_age','male_age','confidence_level','confidence_type','popthresh')]
              
              # rename columns
              names(feature)[names(feature)=='mean'] <- 'pop_mean'
              names(feature)[names(feature)=='median'] <- 'pop_median'
              names(feature)[names(feature)=='lower'] <- 'pop_lower'
              names(feature)[names(feature)=='upper'] <- 'pop_upper'
              
              # remove unwanted columns
              for(name in c('belowthresh','agesexid')) feature[,name] <- NULL
              
              # add settings to woprized results
              feature[,names(ct)] <- ct
              
              # modal to download results
              showModal(modalDialog(rv$dict[['lg_gson_download']],
                                    footer = tagList(
                                      downloadButton("download_geojson",rv$dict[['lg_save_gson']]),
                                      downloadButton("download_spreadsheet",rv$dict[['lg_save_csv']]),
                                      modalButton(rv$dict[['lg_close']])),
                                    title = 'Results')
              )
              
              # download results as geojson
              output$download_geojson <- downloadHandler(
                filename = function() {
                  paste0('woprized_', gsub('.json','.geojson',input$user_json[,'name'],fixed=T))
                },
                content = function(file) {
                  sf::st_write(obj = feature,
                               dsn = file,
                               driver = 'GeoJSON',
                               quiet = TRUE)
                },
                contentType = 'application/json')
              
              # download results as csv
              output$download_spreadsheet <- downloadHandler(
                filename = function() {
                  paste0('woprized_', tools::file_path_sans_ext(input$user_json[,'name']), '.csv')
                },
                content = function(file) {
                  write.csv(x = sf::st_drop_geometry(feature),
                            file = file,
                            row.names = FALSE)
                },
                contentType = 'application/json')
              
              # shinyjs::reset('user_json')
              # mapProxyFile()
              # rv$feature <- NULL
            }
            
            if(input$pointpoly %in% c('Selected Point', 'Custom Area')) {
              if(version_info[input$data_select,'local_sql'] & version_info[input$data_select,'local_agesex_table']){
                
                # query local SQL
                i <- getPopSql(cells=cellids(rv$feature, rv$mastergrid),
                               db=rv$sql,
                               agesex_select=rv$agesex_select,
                               agesex_table=rv$agesex_table,
                               get_agesexid=T)
                rv$N <- i[['N']]
                rv$agesexid <- as.character(i[['agesexid']])
                
              } else {
                
                # query wopr
                i <- getPop(feature=rv$feature,
                            country=rv$country,
                            version=rv$version,
                            agesex_select=rv$agesex_select,
                            get_agesexid=T,
                            url=url)
                rv$N <- i[['N']]
                rv$agesexid <- as.character(i[['agesexid']])
                
              }
            }
            
          }, warning=function(w){
            
            showNotification(as.character(w), type='warning', duration=20)
            
            if(input$pointpoly=='Upload File') shinyjs::reset('user_json')
            
          }, error=function(e){
            
            showNotification(as.character(e), type='error', duration=20)
            
            if(input$pointpoly=='Upload File') shinyjs::reset('user_json')
            
          })
        }, message='woprizing:',
        detail=rv$dict[['lg_woprizing_message']],
        value=1)
      }
      shinyjs::enable('submit')
    })
    
    ##-- create plot --##
    output$sidePlot <- renderPlot({
      
      plotPanel(N=rv$N,
                agesex_select=rv$agesex_select,
                agesex_table=rv$agesex_table[rv$agesex_table$id==rv$agesexid,],
                confidence=input$ci_level,
                tails=input$ci_type,
                popthresh=input$popthresh,
                popmax=version_info[input$data_select,'popmax'],
                dict=rv$dict)
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
        
        showNotification(rv$dict[['lg_saving_message']], type='message', duration=10)
      } else {
        showNotification(rv$dict[['lg_saving_eror']], type='message')
      }
      shinyjs::reset('save_name')
    })
    
    ##-- saved tab --##
    
    # results table
    output$results_table <- renderTable( rv$table[,-which(names(rv$table) %in% c('message','geojson'))],
                                         digits = 3,
                                         striped = T,
                                         format.args = list(big.mark=",", decimal.mark="."),
                                         rownames = F)
    
    # download button
    output$download_table <- downloadHandler(filename = function(timestamp=format(Sys.time(), "%Y%m%d%H%M")) paste0('woprVision_',timestamp,'.csv'),
                                             content = function(file) {
                                               idrop <- which(sapply(rv$table[,'geojson'], nchar) > 32767)
                                               if(length(idrop) > 0){
                                                 rv$table[idrop,'geojson'] <- NA
                                                 showNotification(rv$dict[['lg_geojson_error']], type='warning', duration=20)
                                               }
                                               write.csv(rv$table, file, row.names=FALSE)
                                             })
    # clear button
    observeEvent(input$clear_button, {
      showModal(modalDialog(rv$dict[['lg_clear_save']],
                            title=rv$dict[['lg_confirm']],
                            footer=tagList(
                              actionButton('clear',rv$dict[['lg_clear_button']]),
                              modalButton(rv$dict[['lg_cancel']]))
      ))
    })
    observeEvent(input$clear, {
      rv$table <- NULL
      removeModal()
    })
    observeEvent(is.null(rv$table), {
      if(is.null(rv$table)){
        shinyjs::disable('download_table')
        shinyjs::disable('clear_button')
      } else {
        shinyjs::enable('download_table')
        shinyjs::enable('clear_button')
      }
    })
    
    ##-- translation --##
    observeEvent(input$lang_select, {
      
      rv$N <- rv$agesexid <- NULL
      rv$dict <- list()
      translate <- function(str){
        rv$dict[[str]] <- ifelse(is.null(eval(parse(text=paste0('dict_', input$lang_select)))[[str]]), 
                                 dict_EN[[str]], 
                                 eval(parse(text=paste0('dict_', input$lang_select)))[[str]])
        output[[str]] <- renderUI(rv$dict[[str]])
      }
      
      lapply(keys, function(u) translate(u))
      
      # specific case: confidence type
      output$confidence_type <- renderText(
        return(paste0(
          '<div class="form-group shiny-input-container">
          <label class="control-label" for="ci_type">
          <h5><div id="lg_confidence_type" class="shiny-html-output"></div></h5>
          </label>
          <div><select id="ci_type"><option value="Interval" selected>',rv$dict[['lg_interval']],'</option>
          <option value="Lower Limit">',rv$dict[['lg_lower']],'</option>
          <option value="Upper Limit">',rv$dict[['lg_upper']],'</option></select>
          <script type="application/json" data-for="ci_type" data-nonempty="">{}</script></div>
          </div>'
        ))
      )
    })
    
    
    ##-- tabs --##
    
    # help tab
    observeEvent(input$lang_select,{
      output$helpfile <- renderText(
        return(paste('<iframe style="height: calc(97vh - 80px); width:100%" src="',
                     rv$dict[["lg_helpfile"]], '", frameBorder="0"></iframe>', sep = ""))
      )
    })
    
    # wopr download tab
    observeEvent(input$download_link, {
      showModal(modalDialog(HTML(paste0(input$data_select, rv$dict[['lg_download_popup']],a(href=rv$wopr_url, target='_blank', rv$wopr_url))),
                            title = rv$dict[['lg_data_download']],
                            easyClose = TRUE,
                            footer = modalButton("OK"))
      )
    })
    
    # readme tab
    
    output$data_readme <- renderText(
      return(paste('<iframe style="height: calc(97vh - 80px); width:100%" src="', 
                   rv$data_readme_url, 
                   '", frameBorder="0"></iframe>', sep = ""))
    )
    
    # login tab
    
    
    observeEvent(input$login_input, {
      req(input$login_input)
      
      showModal(modalDialog(
        textInput("username", rv$dict[["lg_username"]]),
        passwordInput("password", rv$dict[["lg_password"]]),
        easyClose = TRUE,
        footer = tagList(
          actionButton("login_output", "OK")
        )
      ))
      
      
    }, priority=500)  
    
    #-- unlock data with login --#
    
    observeEvent(input$login_output, {
      updateNavbarPage(session, 'navbar_id', selected = 'panel_map')
      
      removeModal()
      rv$password <- input$password
      rv$username <- input$username
      
      token_returned <- getToken_ESRI(rv$username, rv$password)
      
      if(token_returned==400){
        showModal(modalDialog(
          title = rv$dict[["lg_failed_login"]] ,
          rv$dict[["lg_invalid_login"]] ,
          easyClose = TRUE,
          footer = NULL
        ))
      } else if (is.numeric(token_returned)){
        showModal(modalDialog(
          title = rv$dict[["lg_failed_login"]] ,
          rv$dict[["lg_issue_token"]],
          easyClose = TRUE,
          footer = NULL
        ))
      } else{
        
        rv$token <- token_returned
        updateSelectInput(session, 'data_select',
                          choices = sort(paste(c(version_info_default$country, substr(input$username, 1,3)), 
                                               c(version_info_default$version, chartr("_", ".", substring(input$username, 4))))),
                          selected = paste( substr(input$username, 1,3), chartr("_", ".", substring(input$username, 4))))
        
        updateActionLink(session, 'login_input', icon=icon('lock-open'))
        
        
        
        
      }
      
      updateNavbarPage(session, 'navbar_id', selected = 'panel_map')
      
      
      
    })
    
    
  })




