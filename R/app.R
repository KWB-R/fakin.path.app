# Define UI for application ----------------------------------------------------
get_ui <- function() shiny::fluidPage(
  
  # Application title
  shiny::titlePanel("Analyse Paths"),
  
  # Sidebar with a slider input for number of bins 
  shiny::verticalLayout(
    shiny::mainPanel(
      width = 12,
      shiny::tabsetPanel(
        shiny::tabPanel("Table", fileDataUI("id_fileData")),
        shiny::tabPanel("Sankey", sankeyUI("id_sankey")),
        shiny::tabPanel("Explore", exploreUI("id_explore")),
        shiny::tabPanel("Treemap", treemapUI("id_treemap")),
        shiny::tabPanel("Files in depth", depthUI("id_depth")),
        shiny::tabPanel("Stats", statsUI("id_stats"))
      )
    )
  )
)

# Define server logic ----------------------------------------------------------
server <- function(input, output)
{
  filtered_path_list <- shiny::callModule(fileData, "id_fileData")
  
  # Call the sankey module. The id needs to be passed to the server function.
  # It is required to name the output that is generated dynamically.
  # Take care: do not use a helper variable to pass the id but a constant 
  # string, as in the following 
  shiny::callModule(
    sankey, "id_sankey", path_list = filtered_path_list, id = "id_sankey"
  )
  
  shiny::callModule(explore, "id_explore", path_data = filtered_path_list)
  shiny::callModule(mytreemap, "id_treemap", path_data = filtered_path_list)
  shiny::callModule(depth, "id_depth", path_data = filtered_path_list)
  shiny::callModule(stats, "id_stats", path_data = filtered_path_list)
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
