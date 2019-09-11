# treemapUI --------------------------------------------------------------------

#' @importFrom shiny mainPanel NS plotOutput radioButtons sidebarLayout 
#' @importFrom shiny sidebarPanel sliderInput
#' @keywords internal
treemapUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      width = get_global("sidebar_width"),
      shiny::sliderInput(
        inputId = ns("n_levels"), 
        label = "Levels shown", 
        min = 1, max = 3, step = 1, value = 1
      ),
      shiny::radioButtons(
        inputId = ns("treemap_type"), 
        label = "Rectangle area represents", 
        choices = c("total size" = "size", "total number of files" = "files")
      )
    ),
    shiny::mainPanel(
      shiny::plotOutput(ns("plot"), height = get_global("plot_height"))
    )
  )
}

# mytreemap --------------------------------------------------------------------

#' @importFrom kwb.utils selectColumns
#' @importFrom shiny renderPlot
#' @keywords internal
mytreemap <- function(input, output, session, path_list)
{
  output$plot <- shiny::renderPlot({
    
    types <- kwb.utils::selectColumns(path_list()@data, "type")
    
    if (! any(types == "file")) {
      plot_centered_message(paste0(
        "No file data available.\n", 
        "You may need to remove a filter on 'directories'"
      ))
    } else {
      plot_treemaps_from_path_data(
        path_list(),
        n_levels = input$n_levels, 
        types = input$treemap_type
      )
    }
  })
}
