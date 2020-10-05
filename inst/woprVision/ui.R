# left panel: user inputs
inputs <-
  column(
    width=2,
    style=paste0('height: calc(98vh - 75px); padding:30px; overflow-y:scroll; border: 1px solid ',gray(0.9),'; background:',gray(0.95)),
    shinyjs::useShinyjs(),
    
    fluidRow(
      
      # model
      selectInput('data_select',
                  HTML(paste(uiOutput('lg_select_data1', inline=T),'<br><small>(',uiOutput('lg_select_data2', inline=T),'<a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3" target="_blank">',uiOutput('lg_select_data3', inline=T), '</a>)</small>')),
                  choices=paste(version_info$country, version_info$version),
                  selected=data_init),
      
      
      # output type (point/polygon)
      radioButtons('pointpoly',
                   uiOutput('lg_select_location'),
                   choiceNames=list(uiOutput('lg_click_map'),uiOutput('lg_draw_area'),uiOutput('lg_upload_gjson')),
                   choiceValues=c('Selected Point','Custom Area','Upload File')),
      # upload geojson
      # tags$style(".shiny-file-input-progress {display: none}"),
      
      fileInput("user_json", NULL,
                multiple = FALSE,
                accept = c('.geojson','.json'),
                buttonLabel = uiOutput('lg_browse'),
                placeholder = 'No file selected'),
      
      # age-sex groups
      strong(uiOutput('lg_define_agesex')),
      
      tags$style('.irs-bar, .irs-bar-edge,
               .irs-single, .irs-from, .irs-to, .irs-grid-pol {background-color:darkgrey; border-color:darkgrey; }'),
      
      # female
      splitLayout(cellWidths=c('35%','65%'),
                  checkboxInput(inputId="female", label=uiOutput("lg_female"), value=T),
                  shinyWidgets::sliderTextInput(inputId="female_select",
                                                label=NULL,
                                                choices=agesex_choices,
                                                selected=c('<1','80+'),
                                                force_edges=T)),
      # male
      splitLayout(cellWidths=c('35%','65%'),
                  checkboxInput(inputId="male", label=uiOutput("lg_male"), value=T),
                  shinyWidgets::sliderTextInput(inputId="male_select",
                                                label=NULL,
                                                choices=agesex_choices,
                                                selected=c('<1','80+'),
                                                force_edges=T)),
      
      # submit button
      strong(uiOutput('lg_get_pop_estimates')), br(),
      
      tags$style(HTML('#submit{background-color:#383838; color:white}')),
      
      shinyjs::disabled(actionButton('submit',strong(uiOutput('lg_submit')),width='100%')), br(), br(),
      
      # save estimate
      strong(uiOutput('lg_save_result')), br(),
      
      splitLayout(cellWidths=c('30%','70%'),
                  
                  shinyjs::disabled(actionButton('save_button', uiOutput('lg_save'), width='100%')),
                  
                  textInput('save_name',
                            label=NULL,
                            value='',
                            width='100%',
                            placeholder='Result Name (optional)')),
      
      # age-sex groups
      br(),strong(uiOutput('lg_options')),
      
      # confidence level
      sliderInput('ci_level',h5(uiOutput('lg_confidence_level')), min=50, max=99, value=95, step=5),
      htmlOutput("confidence_type"),
      numericInput('popthresh', h5(uiOutput('lg_pop_threshold')), value=100, min=0, max=1e6, step=1)
    )
  )



# main panel
ui <- fluidPage(
  tagList(

    tags$head(
      tags$meta(name='description', content='woprVision is an interactive web map that allows you to query population estimates for specific locations and demographic groups from the WorldPop Open Population Repository.'),
      tags$meta(name='keywords', content='WorldPop, WOPR, woprVision, wopr vision, WorldPop Open Population Repository, population, spatial data, population map, gridded population, Bayesian statistics, shiny, R package, Nigeria, DRC, Democratic Republic of the Congo')
    ),
    
    tags$style(HTML(".navbar-nav {float:none !important;}
                  .navbar-nav > li:nth-child(6){float:right}
                  .navbar-nav > li:nth-child(7){float:right}
                  .navbar-nav > li:nth-child(8){float:right}
                  .navbar-nav > li:nth-child(9){float:right}")),
    
    tags$style(HTML(".leaflet-container {background:#2B2D2F; cursor:pointer}")),
    
    tags$style("#lang_div .selectize-control {margin-bottom:-15px; margin-top:10px; margin-left:10px; margin-right:5px; z-index:10000;}"),

    tags$div(id='lang_div',
             style="display:inline-block; float:right",
             selectInput("lang_select",
                         NULL,
                         choices=c("EN", "ES", "FR", "PT"),
                         selected= "EN",
                         width="80px", 
                         selectize = T)),
    
    navbarPage(title='woprVision (beta)',
               footer=tags$footer(HTML(paste0('Source data: <a href="https://wopr.worldpop.org" target="_blank">WorldPop Open Population Repository (WOPR)</a>, Source code: <a href="https://github.com/wpgp/wopr" target="_blank">wopr R package v',packageVersion('wopr'),'</a>')), align='right'),
               inverse=F,
               id="navbar_id",
               
               tabPanel(uiOutput('lg_map_name'),
                        value="panel_map",
                        id="panel_map",
                        fluidRow(
                          
                          # inputs panel (left)
                          inputs,
                          
                          # map panel (center)
                          column(width = 7,
                                 tags$style(type="text/css","#map {height: calc(98vh - 75px) !important;}"),
                                 leaflet::leafletOutput('map')),
                          
                          # results panel (right)
                          column(width = 3,
                                 style='overflow-y:scroll; height: calc(98vh - 75px)',
                                 plotOutput('sidePlot', height='600px', width='100%')))
               ),
               
               # tab: saved estimates
               tabPanel(uiOutput('lg_saved'),
                        HTML(paste0('<strong>', uiOutput('lg_tab_saved1', inline=T), '<br>',
                                    uiOutput('lg_tab_saved2', inline=T), '</strong><br><br>')),
                        downloadButton('download_table', uiOutput('lg_download', inline=T)),
                        actionButton('clear_button', uiOutput('lg_clear', inline=T)),
                        br(),
                        div(style='overflow-y:scroll; height:calc(98vh - 169px);',
                            tableOutput('results_table'))
               ),
               
               # tab: data readme
               tabPanel(uiOutput('lg_readme_data'),
                        htmlOutput('data_readme')),
               
               # tab: data download
               tabPanel(actionLink('download_link', uiOutput('lg_data_download'), style = 'padding:0px; margin:-15px 15px 0px 15px')),
               
               # tab: help
               tabPanel(uiOutput('lg_help'),
                        htmlOutput('helpfile')),
               
               # tab: WorldPop
               tabPanel(a(href='https://www.worldpop.org', target='_blank', style='padding:0px',
                          img(src='logoWorldPop.png', style='height:30px; margin-top:-30px; margin-left:10px'))),
               
               # tab: Apps
               tabPanel(a(href='https://apps.worldpop.org', target='_blank', style='margin-top:-30px; margin-left:10px', 'Apps')),
               
               # tab: API 
               tabPanel('REST API',
                        tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 80px)',
                                    frameBorder="0",
                                    src='woprAPI.html')),
               
               # tab: R package
               tabPanel(uiOutput('lg_r_package'),
                        tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 80px)',
                                    frameBorder='0',
                                    src='wopr_README.html'))
    )
  )
)
