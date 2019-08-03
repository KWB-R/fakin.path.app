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
        shiny::tabPanel("Statistics", statsUI("id_stats")),
        shiny::tabPanel("Sankey", sankeyUI("id_sankey")),
        shiny::tabPanel("Treemap", treemapUI("id_treemap")),
        shiny::tabPanel("Scatter", depthUI("id_depth")),
        shiny::tabPanel("Frequencies", wordcloudUI("id_wordcloud")),
        shiny::tabPanel("Explore", exploreUI("id_explore"))
      )
    )
  )
)

# Define server logic ----------------------------------------------------------
server <- function(input, output)
{
  path_list <- shiny::callModule(fileData, "id_fileData")
  
  # Call the sankey module. The id needs to be passed to the server function.
  # It is required to name the output that is generated dynamically.
  # Take care: do not use a helper variable to pass the id but a constant 
  # string, as in the following 
  shiny::callModule(
    sankey, "id_sankey", path_list = path_list, id = "id_sankey"
  )
  
  shiny::callModule(explore, "id_explore", path_list = path_list)
  shiny::callModule(mytreemap, "id_treemap", path_list = path_list)
  shiny::callModule(depth, "id_depth", path_list = path_list)
  shiny::callModule(stats, "id_stats", path_list = path_list)
  shiny::callModule(wordcloud, "id_wordcloud", path_list = path_list)
}

# run_app(): Run the application -----------------------------------------------

#' Run the Shiny App
#' 
#' @param path_database if not \code{NULL} the path to a folder containing 
#'   text files with path information
#' @param \dots further \code{key = value} pairs to be used as global variables
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
