# Define UI for application ----------------------------------------------------

#' @importFrom shiny fluidPage titlePanel verticalLayout mainPanel tabsetPanel
#' @importFrom shiny tabPanel
#' @keywords internal
get_ui <- function() 
{
  shiny::fluidPage(
    shiny::titlePanel("Analyse Paths"),
    shiny::verticalLayout(
      shiny::mainPanel(
        width = 12, shiny::tabsetPanel(
          shiny::tabPanel("Table", fileDataUI("fileData")),
          shiny::tabPanel("Statistics", statsUI("stats")),
          shiny::tabPanel("Duplicates", duplicatesUI("duplicates")),
          shiny::tabPanel("Sankey", sankeyUI("sankey")),
          shiny::tabPanel("Treemap", treemapUI("treemap")),
          shiny::tabPanel("Scatter", depthUI("depth")),
          shiny::tabPanel("Frequencies", wordcloudUI("wordcloud")),
          shiny::tabPanel("Explore", exploreUI("explore"))
        )
      )
    )
  )
}

# Define server logic ----------------------------------------------------------

#' @importFrom shiny callModule
#' @keywords internal
server <- function(input, output, session)
{
  path_list <- shiny::callModule(fileData, "fileData")
  
  # Call the sankey module. The id needs to be passed to the server function.
  # It is required to name the output that is generated dynamically.
  # Take care: do not use a helper variable to pass the id but a constant 
  # string, as in the following 
  shiny::callModule(sankey, "sankey", path_list = path_list, id = "sankey")
  shiny::callModule(explore, "explore", path_list = path_list)
  shiny::callModule(mytreemap, "treemap", path_list = path_list)
  shiny::callModule(depth, "depth", path_list = path_list)
  shiny::callModule(stats, "stats", path_list = path_list)
  shiny::callModule(duplicates, "duplicates", path_list = path_list)
  shiny::callModule(wordcloud, "wordcloud", path_list = path_list)
  
  session$onSessionEnded(shiny::stopApp)
}

# run_app(): Run the application -----------------------------------------------

#' Run the Shiny App
#' 
#' @param path_database if not \code{NULL} the path to a folder containing 
#'   text files with path information
#' @param \dots further \code{key = value} pairs to be used as global variables
#' @importFrom shiny shinyApp
#' @export
run_app <- function(path_database = NULL, ...)
{
  # Set defaults (1. hard coded, 2. from environment variables, 3. from user)
  set_global(list. = default_globals())
  set_global(list. = get_environment_vars("^PATHANA_"))
  
  if (! is.null(path_database)) {
    set_global(path_database = path_database)
  }
  
  if (length(list(...))) {
    set_global(...)
  }  
  
  shiny::shinyApp(ui = get_ui(), server = server)
}
