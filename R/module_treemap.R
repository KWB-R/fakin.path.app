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

# mytreemap --------------------------------------------------------------------
mytreemap <- function(input, output, session, path_data)
{
  message("render treemap")
  
  output$plot <- shiny::renderPlot({
    kwb.fakin::plot_treemaps_from_path_data(
      path_data(),
      n_levels = input$n_levels, 
      types = input$treemap_type
    )
  })
  
  message("back from render treemap.")
}
