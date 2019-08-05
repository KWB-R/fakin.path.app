# duplicatesUI -----------------------------------------------------------------

#' @importFrom shiny NS sidebarLayout sidebarPanel sliderInput mainPanel
#' @importFrom DT dataTableOutput
#' @keywords internal
duplicatesUI <- function(id)
{
  ns <- shiny::NS(id)

  shiny::sidebarLayout(
    shiny::sidebarPanel(
      width = get_global("sidebar_width"),
      shiny::sliderInput(
        inputId = ns("min_size"), label = "Min. File Size in MiB", 
        min = 1, max = 1000, value = 10, step = 10
      )
    ),
    shiny::mainPanel(
      width = 12 - get_global("sidebar_width"),
      DT::dataTableOutput(ns("table"), height = get_global("plot_height"))
    )
  )
}

# duplicates -------------------------------------------------------------------

#' @importFrom DT renderDataTable
#' @keywords internal
duplicates <- function(input, output, session, path_list)
{
  output$table <- DT::renderDataTable({
    
    duplicates <- find_duplicates(path_list(), input$min_size)
    
    potential <- fakin.path.app:::duplicates_to_saving_potential(duplicates)
    
    DT::datatable(potential) %>%
      DT::formatRound(columns = c("size", "potential"), digits = 3)
  })
}
