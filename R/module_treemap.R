# treemapUI --------------------------------------------------------------------
treemapUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(6, shiny::sliderInput(
        inputId = ns("n_levels"), 
        label = "Levels shown", 
        min = 1, max = 3, step = 1, value = 2
      )),
      shiny::column(6, inlineRadioButtons(
        inputId = ns("treemap_type"), 
        label = "Area represents", 
        choices = c("total size" = "size", "total number of files" = "files")
      ))
    ),
    shiny::plotOutput(ns("plot"))
  )
}

# treemap ----------------------------------------------------------------------
treemap <- function(input, output, session)
{
  message("in treemap()")
  # output$treemap <- shiny::renderPlot({
  #   kwb.fakin::plot_treemaps_from_path_data(
  #     provide_data(x = file_info_raw(), input), 
  #     n_levels = input$n_levels, types = input$treemap_type
  #   )
  # })
}
