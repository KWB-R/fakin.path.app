# multiplotUI ------------------------------------------------------------------
multiplotUI <- function(id, max_plots)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::sliderInput(
      inputId = ns("n_plots"), 
      label = "Number of plots", 
      min = 1, max = max_plots, value = 2
    ),
    shiny::uiOutput(ns("plot"))
  )
}

# multiplot --------------------------------------------------------------------
multiplot <- function(input, output, session)
{
  # observe({
    output$plot <- renderUI({
      get_plot_outputs(input$n_plots)
    })
  # })
}

# get_plot_outputs -------------------------------------------------------------
get_plot_outputs <- function(input_n)
{
  # Insert plot output objects the list
  plot_outputs <- lapply(1:input_n, function(i) {
    
    plotname <- paste0("plot_", i)
    
    plot_output_object <- renderPlot({
      barplot(1:i, main = paste0("i: ", i, ", n is ", input_n, sep = ""))
    })
  })
  
  do.call(tagList, plot_outputs) # needed to display properly.
  
  plot_outputs
}
