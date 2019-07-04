# depthUI ----------------------------------------------------------------------
depthUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(4, shiny::sliderInput(
        inputId = ns("n_root_parts"), 
        label = "Root folder levels", 
        min = 1, max = 3, step = 1, value = 2
      )),
      shiny::column(4, inlineRadioButtons(
        inputId = ns("group_aesthetics"),
        label = "Group aesthetics",
        choices = c("colour", "shape")
      )),
      shiny::column(4, inlineRadioButtons(
        inputId = ns("group_by"),
        label = "Group by",
        choices = c("extension", "level-1")
      ))
    ),
    shiny::plotOutput(ns("plot"))
  )
}

# depth ------------------------------------------------------------------------
depth <- function(input, output, session)
{
  output$depth <- shiny::renderPlot({
    provide_data(x = file_info_raw(), input) %>%
      kwb.fakin:::prepare_for_scatter_plot(
        n_root_parts = input$n_root_parts
      ) %>%
      kwb.fakin:::plot_file_size_in_depth(
        main = "Total", 
        group_aesthetics = input$group_aesthetics, 
        group_by = input$group_by
      )
  })
  
}
