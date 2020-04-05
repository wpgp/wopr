# left panel: user inputs
inputs <- 
column(
  width=2,
  style=paste0('height: calc(98vh - 75px); padding:30px; overflow-y:scroll; border: 1px solid ',gray(0.9),'; background:',gray(0.95)),
  shinyjs::useShinyjs(),

  fluidRow(
    
    # model
    selectInput('data_select', 
                HTML('1. Choose Population Data<br><small>(see <a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3" target="_blank">country codes</a>)</small>'),
                choices=paste(version_info$country, version_info$version), 
                selected=data_init),

    # output type (point/polygon)
    radioButtons('pointpoly',
                 '2. Select a Location',
                 choiceNames=list('Click the map','Draw an area','Upload GeoJSON file'), 
                 choiceValues=c('Selected Point','Custom Area','Upload File')),
    
    # upload geojson
    tags$style(".shiny-file-input-progress {display: none}"),
    
    fileInput("user_json", NULL,
              multiple = FALSE,
              accept = ".json",
              buttonLabel = 'Browse',
              placeholder = '.json'),
    
    # age-sex groups
    strong('3. Define Age-sex Groups'),
    
    tags$style('.irs-bar, .irs-bar-edge,
               .irs-single, .irs-from, .irs-to, .irs-grid-pol {background-color:darkgrey; border-color:darkgrey; }'),
    
    # female
    splitLayout(cellWidths=c('35%','65%'),
                checkboxInput(inputId="female", label="Female", value=T),
                shinyWidgets::sliderTextInput(inputId="female_select", 
                                              label=NULL, 
                                              choices=c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+'),
                                              selected=c('<1', '80+'),
                                              force_edges=T)),
    # male
    splitLayout(cellWidths=c('35%','65%'),
                checkboxInput(inputId="male", label="Male", value=T),
                shinyWidgets::sliderTextInput(inputId="male_select", 
                                              label=NULL, 
                                              choices=c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+'),
                                              selected=c('<1', '80+'),
                                              force_edges=T)),

    # submit button
    strong('4. Get Population Estimate'), br(),
    
    tags$style(HTML('#submit{background-color:#383838; color:white}')),
    
    shinyjs::disabled(actionButton('submit',strong('Submit'),width='100%')), br(), br(),
    
    # save estimate
    strong('5. Save Result'), br(),
    
    splitLayout(cellWidths=c('30%','70%'),
                
                shinyjs::disabled(actionButton('save_button', 'Save', width='100%')), 
                
                textInput('save_name',
                          label=NULL,
                          value='',
                          width='100%',
                          placeholder='Save As (optional)')),
    
    # age-sex groups
    strong('Options:'),br(),
    
    # confidence level
    sliderInput('ci_level',h5('Confidence Level (%):'), min=50, max=99, value=95, step=5),
    selectInput('ci_type',h5('Confidence Type'), choices=c('Interval', 'Lower Limit', 'Upper Limit')),
    numericInput('popthresh', h5('Population Threshold'), value=100, min=0, max=1e6, step=1)
  )
)

# main panel
ui <- tagList(
  tags$head(includeScript("google-analytics.js")),
  
  tags$head(
    tags$meta(name='description', content='woprVision is an interactive web map that allows you to query population estimates for specific locations and demographic groups from the WorldPop Open Population Repository.'),
    tags$meta(name='keywords', content='WorldPop, WOPR, woprVision, wopr vision, WorldPop Open Population Repository, population, spatial data, population map, gridded population, Bayesian statistics, shiny, R package, Nigeria, DRC, Democratic Republic of the Congo')
  ),
  
  tags$style(HTML(".navbar-nav {float:none !important;}
                  .navbar-nav > li:nth-child(3){float:right}
                  .navbar-nav > li:nth-child(4){float:right}
                  .navbar-nav > li:nth-child(5){float:right}
                  .navbar-nav > li:nth-child(6){float:right}
                  .navbar-nav > li:nth-child(7){float:right}")),
  
  tags$style(HTML(".leaflet-container {background:#2B2D2F; cursor:pointer}")),
  
  navbarPage(title='woprVision (beta)', 
             # footer=tags$footer('wopr v0.2 (R package)', align='right'),
             inverse=F,

             # tab: map
             tabPanel('Map',
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
             tabPanel('Saved', 
                      downloadButton('download_table', 'Download'),
                      actionButton('clear_button', 'Clear'),
                      br(),
                      div(style='overflow-y:scroll; max-height:calc(98vh - 120px)',
                          tableOutput('results_table'))
             ),
             
             # tab: WorldPop
             tabPanel(a(href='https://www.worldpop.org', target='_blank', 
                        style='padding:0px',
                            img(src='logoWorldPop.png', 
                                style='height:30px; margin-top:-30px; margin-left:10px'))),

             # tab: API readme
             tabPanel('REST API',
                      tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 75px)',
                                  frameBorder="0",
                                  src='woprAPI.html')),
             
             # tab: wopr R package readme
             tabPanel('R package',
                      tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 75px)',
                                  frameBorder='0',
                                  src='wopr_README.html')),
             
             # tab: wopr
             tabPanel('WOPR Download',
                      htmlOutput('wopr_web')),
             
             # tab: data readme
             tabPanel('Data Readme',
                      htmlOutput('data_readme')),
             
             # tab: API readme
             tabPanel('Help',
                      tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 75px)',
                                  src='woprVision.html',
                                  frameBorder="0"))
             
  )
)
