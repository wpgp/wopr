# left panel: user inputs
inputs <- 
  column(
    width=2,
    style=paste0('height: calc(98vh - 80px); padding:30px; overflow-y:scroll; border: 1px solid ',gray(0.9),'; background:',gray(0.95)),
    tags$head(
      tags$style(HTML("hr {border-top: 1px solid #a6a6a6;}"))
    ),
    
    fluidRow(
      
      # model
      selectInput('data_select', 
                  'Population Data', 
                  choices=paste(catalogue$country, catalogue$version), 
                  selected=data_init),
      
      # submit button
      div(style='display:inline-block; float:right', {
        actionButton('submit','Submit')
      }), 
      
      # output type (point/polygon)
      radioButtons('pointpoly',
                   'Selection Tool',
                   choiceNames=list('Click the map','Draw an area'), 
                   choiceValues=c('Selected Point','Custom Area')),
      
      # age-sex groups  
      strong('Age-sex Groups'),
      
      # female
      splitLayout(cellWidths=c('30%','70%'),
                  checkboxInput(inputId="female", label="Female", value=T),
                  shinyWidgets::sliderTextInput(inputId="female_select", 
                                                label=NULL, 
                                                choices=c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+'),
                                                selected=c('<1', '80+'),
                                                force_edges=T)),
      
      # male
      splitLayout(cellWidths=c('30%','70%'),
                  checkboxInput(inputId="male", label="Male", value=T),
                  shinyWidgets::sliderTextInput(inputId="male_select", 
                                                label=NULL, 
                                                choices=c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+'),
                                                selected=c('<1', '80+'),
                                                force_edges=T)),
      
      # save estimate
      div(style='display:inline-block; float:right', {
        actionButton('save_button', 'Save')
      }),
      textInput('save_name',
                label=NULL,
                value='',
                width='70%',
                placeholder='Save Result As'),
      hr(),

      # confidence level
      sliderInput('ci_level','Confidence Level (%):', min=50, max=99, value=95, step=5),
      
      selectInput('ci_type','Confidence Type', choices=c('Interval', 'Lower Limit', 'Upper Limit')),
      
      # radioButtons('ci_type','Confidence Type', choices=c('Interval', 'Lower Limit', 'Upper Limit')),
      numericInput('popthresh', 'Population Threshold', value=100, min=0, max=1e6, step=1),
      
      hr(),
      
      # access key
      textInput('key', NULL, key, placeholder='Access Key')
      )
  )

# main panel
navbarPage(footer='wopr v0.2, WorldPop Research Group, University of Southampton',
           title='woprVision', 
           
           # tab 1: map
           tabPanel('Map',
                    fluidRow(
                      
                      # inputs panel (left)
                      inputs,
                      
                      # map panel (center)
                      column(width = 7,
                             tags$style(type="text/css","#map {height: calc(98vh - 80px) !important;}"),
                             leafletOutput('map')),
                      
                      # results panel (right)
                      column(width = 3,
                             style='overflow-y:scroll; height: calc(98vh - 80px)',
                             plotOutput('sidePlot', height='600px', width='100%')))
           ),
           
           # tab 2: saved estimates
           tabPanel('Saved Estimates', 
                    style='overflow-y:scroll; max-height:700px',
                    br(),
                    downloadButton('download_table', 'Download'),
                    actionButton('clear_button', 'Clear'),
                    br(),
                    tableOutput('results_table')
           ),
           
           # tab 3: data readme
           tabPanel('Data Readme',
                    style='height: calc(98vh - 80px)',
                    htmlOutput('data_readme'))
)
