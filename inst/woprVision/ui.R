# left panel: user inputs
inputs <- 
  column(
    width=2,
    style=paste0('height: calc(98vh - 80px); padding:30px; overflow-y:scroll; border: 1px solid ',gray(0.9),'; background:',gray(0.95)),

    fluidRow(
      
      # model
      selectInput('data_select', 
                  'Population Data', 
                  choices=paste(catalogue$country, catalogue$version), 
                  selected=data_init),
      
      # submit button
      shinyjs::useShinyjs(),
      
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
      textInput('key', NULL, wopr_key, placeholder='Access Key')
      )
  )

# main panel
ui <- tagList(
  
  tags$style(HTML(".navbar-nav {float:none !important;}
                  .navbar-nav > li:nth-child(3){float:right}
                  .navbar-nav > li:nth-child(4){float:right}
                  .navbar-nav > li:nth-child(5){float:right}
                  .navbar-nav > li:nth-child(6){float:right}
                  .navbar-nav > li:nth-child(7){float:right}")),
  
  tags$style(HTML(".leaflet-container {background:#2B2D2F")),
  
  navbarPage(title='woprVision', 
             footer='wopr v0.2 (R package), WorldPop, University of Southampton',
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
