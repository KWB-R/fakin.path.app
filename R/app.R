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
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      width = 4,
      csvFileUI("csv", GLOBALS$path_database),
      commonRootUI("common_root"),
      filterControlsUI("filter_controls")
    ),
    
    # Show a plot of the generated distribution
    shiny::mainPanel(
      shiny::tabsetPanel(
        shiny::tabPanel("Table", fileDataUI("file_data")),
        shiny::tabPanel("Sankey", sankeyUI("sankey")),
        shiny::tabPanel("Treemap", treemapUI("treemap")),
        shiny::tabPanel("Files in depth", depthUI("depth")),
        shiny::tabPanel("Test multiplot", multiPlotUI(
          "multiplot", max_plots = GLOBALS$max_plots
        ))
      )
    )
  )
)

# Define server logic ----------------------------------------------------------
server <- function(input, output)
{
  csv <- shiny::callModule(
    csvFile, "csv", read_function = kwb.fakin::read_file_paths
  )
  
  file_info <- shiny::callModule(
    fileData, "file_data", path = csv$file, file_data = csv$content
  )
  
  shiny::callModule(sankey, "sankey", file_info = file_info)
  # shiny::callModule(treemap, "treemap")
  # shiny::callModule(depth, "depth")
  # shiny::callModule(multiPlot, "multiplot")
}

# run_app(): Run the application -----------------------------------------------

#' Run the Shiny App
#' 
#' @export
run_app <- function()
{
  shiny::shinyApp(ui = get_ui(), server = server)
}
