# depthUI ----------------------------------------------------------------------
depthUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::fluidRow(
      # shiny::column(4, shiny::sliderInput(
      #   inputId = ns("n_root_parts"),
      #   label = "Root folder levels",
      #   min = 1, max = 3, step = 1, value = 2
      # )),
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
  # shiny::sidebarLayout(
  #   shiny::sidebarPanel(
  #     width = get_global("sidebar_width"),
  #     shiny::sliderInput(
  #       inputId = ns("n_root_parts"), 
  #       label = "Root folder levels", 
  #       min = 1, max = 3, step = 1, value = 2
  #     ),
  #     shiny::radioButtons(
  #       inputId = ns("group_aesthetics"),
  #       label = "Group aesthetics",
  #       choices = c("colour", "shape")
  #     ),
  #     shiny::radioButtons(
  #       inputId = ns("group_by"),
  #       label = "Group by",
  #       choices = c("extension", "level-1")
  #     )
  #   ), 
  #   shiny::mainPanel(
  #     shiny::plotOutput(ns("plot"))
  #   )
  # )
}

# depth ------------------------------------------------------------------------
depth <- function(input, output, session, path_data)
{
  # file_data <- shiny::reactive({
  #   
  #   stopifnot(inherits(path_data(), "pathlist"))
  #   
  #   cbind.data.frame(
  #     path_data()@data, 
  #     path = as.character(path_data()), 
  #     stringsAsFactors = FALSE
  #   )
  # })
  
  output$plot <- shiny::renderPlot({

    prepared_data <- kwb.fakin:::prepare_for_scatter_plot2(
      file_data = path_data()
    )
    
    kwb.fakin:::plot_file_size_in_depth(
      df = prepared_data,
      main = "Total",
      group_aesthetics = input$group_aesthetics,
      group_by = input$group_by
    )
  })
}
