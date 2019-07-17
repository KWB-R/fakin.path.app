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
  },
  sankey_height = 600
)
  
# Inputs -----------------------------------------------------------------------

# Define UI for application that draws a histogram
get_ui <- function() shiny::fluidPage(
  
  # Application title
  shiny::titlePanel("Analyse Paths"),
  
  # Sidebar with a slider input for number of bins 
  shiny::verticalLayout(
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
  filtered_path_list <- shiny::callModule(fileData, "id_fileData")
  
  shiny::callModule(sankey, "sankey", path_list = filtered_path_list)
  
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
