#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

GLOBALS <- list(
  max_plots = 5,
  path_database = if (kwb.utils::user() == "hsonne") {
    "//medusa/processing/CONTENTS/file-info_by-department/2019-07"
  } else {
    "~/Desktop/Data/FAKIN/file-info_by-department"
  }
)
  
# Inputs -----------------------------------------------------------------------

# Define UI for application that draws a histogram
get_ui <- function() shiny::fluidPage(
  
  # Application title
  shiny::titlePanel("Analyse Paths"),
  
  # Sidebar with a slider input for number of bins 
  #shiny::sidebarLayout(
  shiny::verticalLayout(
    # shiny::sidebarPanel(
    #   width = 4,
    #   csvFileUI("id_csvFile", GLOBALS$path_database),
    #   #commonRootUI("common_root"),
    #   filterControlsUI("id_filterControls")
    # ),
    
    # Show a plot of the generated distribution
    shiny::mainPanel(
      width = 12,
      shiny::tabsetPanel(
        shiny::tabPanel("Table", fileDataUI("id_fileData")),
        shiny::tabPanel("Sankey", sankeyUI("sankey")),
        shiny::tabPanel("Treemap", treemapUI("treemap")),
        shiny::tabPanel("Files in depth", depthUI("depth"))
        # , shiny::tabPanel("Test multiplot", multiPlotUI(
        #   "multiplot", max_plots = GLOBALS$max_plots
        # ))
      )
    )
  )
)

# Define server logic ----------------------------------------------------------
server <- function(input, output)
{
  if (TRUE) {
    #myCsvFile <- shiny::callModule(csvFile, "id_csvFile")
    
    # myFilterControls <- shiny::callModule(
    #   filterControls, "id_filterControls"
    # )
    # 
    # shiny::observe({
    #   cat(sprintf(
    #     "file: %s\ntype_filter: %s\npath_filter: %s\n",
    #     "<not here any more>", #myCsvFile$file(), 
    #     myFilterControls$type_filter(), 
    #     myFilterControls$path_filter()
    #   ))
    # })
    
    myFileData <- shiny::callModule(
      fileData, "id_fileData"#, myCsvFile, myFilterControls
    )
    
    #shiny::callModule(sankey, "sankey", file_info = file_info)
    # shiny::callModule(treemap, "treemap")
    # shiny::callModule(depth, "depth")
    # shiny::callModule(multiPlot, "multiplot")
  }
}

# run_app(): Run the application -----------------------------------------------

#' Run the Shiny App
#' 
#' @export
run_app <- function()
{
  shiny::shinyApp(ui = get_ui(), server = server)
}
