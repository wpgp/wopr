# left panel: user inputs
inputs <- 
column(
  width=2,
  style=paste0('height: calc(98vh - 80px); padding:30px; overflow-y:scroll; border: 1px solid ',gray(0.9),'; background:',gray(0.95)),
  shinyjs::useShinyjs(),

  fluidRow(
    
    # model
    selectInput('data_select', 
                HTML('1. Choose Population Data<br><small>(see <a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3" target="_blank">country codes</a>)</small>'),
                choices=paste(catalogue$country, catalogue$version), 
                selected=data_init),

    # output type (point/polygon)
    radioButtons('pointpoly',
                 '2. Select a Location',
                 choiceNames=list('Click the map','Draw an area','Upload File'), 
                 choiceValues=c('Selected Point','Custom Area','Upload File')),
    
    # upload geojson
    fileInput("user_json", NULL,
              multiple = FALSE,
              accept = ".json",
              buttonLabel = 'Browse',
              placeholder = '.json'),
    
    # submit button
    strong('3. Submit to WOPR'), br(),
    
    shinyjs::disabled(actionButton('submit','Submit...',width='100%')), br(), br(),
    
    # save estimate
    strong('4. Save Result'), br(),
    
    splitLayout(cellWidths=c('30%','70%'),
                
                shinyjs::disabled(actionButton('save_button', 'Save', width='100%')), 
                
                textInput('save_name',
                          label=NULL,
                          value='',
                          width='100%',
                          placeholder='Save As')),
    
    # age-sex groups
    strong('Options:'),br(),
    
    strong('Age-sex Groups'),
    
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
    # confidence level
    strong('Uncertainty Estimates'),
    sliderInput('ci_level',h5('Confidence Level (%):'), min=50, max=99, value=95, step=5),
    selectInput('ci_type',h5('Confidence Type'), choices=c('Interval', 'Lower Limit', 'Upper Limit')),
    numericInput('popthresh', h5('Population Threshold'), value=100, min=0, max=1e6, step=1)
  )
)

# main panel
ui <- tagList(
  tags$head(includeScript("google-analytics.js")),
  
  tags$style(HTML(".navbar-nav {float:none !important;}
                  .navbar-nav > li:nth-child(3){float:right}
                  .navbar-nav > li:nth-child(4){float:right}
                  .navbar-nav > li:nth-child(5){float:right}
                  .navbar-nav > li:nth-child(6){float:right}
                  .navbar-nav > li:nth-child(7){float:right}")),
  
  tags$style(HTML(".leaflet-container {background:#2B2D2F}")),
  
  navbarPage(title='woprVision', 
             footer='wopr v0.2 (R package)',
             inverse=F,

             # tab: map
             tabPanel('Map',
                      fluidRow(
                        
                        # inputs panel (left)
                        inputs,
                        
                        # map panel (center)
                        column(width = 7,
                               tags$style(type="text/css","#map {height: calc(98vh - 85px) !important;}"),
                               leaflet::leafletOutput('map')),
                        
                        # results panel (right)
                        column(width = 3,
                               style='overflow-y:scroll; height: calc(98vh - 85px)',
                               plotOutput('sidePlot', height='600px', width='100%')))
             ),
             
             # tab: saved estimates
             tabPanel('Saved', 
                      style='overflow-y:scroll; max-height:calc(98vh - 85px)',
                      br(),
                      downloadButton('download_table', 'Download'),
                      actionButton('clear_button', 'Clear'),
                      br(),
                      tableOutput('results_table')
             ),
             
             # tab: WorldPop
             tabPanel(a(href='https://www.worldpop.org', target='_blank', 
                        style='padding:0px',
                            img(src='logoWorldPop.png', 
                                style='height:30px; margin-top:-30px; margin-left:10px'))),

             # tab: API readme
             tabPanel('REST API',
                      tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 85px)',
                                  frameBorder="0",
                                  src='woprAPI.html')),
             
             # tab: wopr R package readme
             tabPanel('R package',
                      tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 85px)',
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
                      tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 85px)',
                                  src='woprVision.html',
                                  frameBorder="0"))
             
  )
)
