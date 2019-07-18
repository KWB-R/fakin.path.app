#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# get_global -------------------------------------------------------------------
get_global <- function(name)
{
  user <- try(kwb.utils::user())
  
  if (inherits(user, "try-error")) {
    user <- "unknown"
  }
  
  globals <- list(
    max_plots = 5,
    path_database = if (user == "hsonne") {
      "//medusa/processing/CONTENTS/file-info_by-department/2019-07"
    } else {
      "~/Desktop/Data/FAKIN/file-info_by-department"
    },
    sankey_height = 600
  )
  
  value <- options()[[paste0("fakin.path.app.", name)]]
  
  if (is.null(value)) {
    kwb.utils::selectElements(globals, name)
  } else {
    value
  }
}
  
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
#' @param path_database if not \code{NULL} the path to a folder containing 
#'   text files with path information
#' @param reactlog logical. The shiny option \code{shiny.reactlog} is set 
#'   accordingly before starting the app
#' @export
run_app <- function(path_database = NULL, reactlog = FALSE)
{
  if (! is.null(path_database)) {
    options(fakin.path.app.path_database = path_database)
  }
  
  options(shiny.reactlog = reactlog) 
  
  shiny::shinyApp(ui = get_ui(), server = server)
}
