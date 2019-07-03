#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(magrittr)

get_file_info_files <- function() {
  files <- c(
    kwb.file::dir_full(kwb.fakin::extdata_file(""), "^example_file_info"),
    kwb.file::dir_full("~/Desktop/Data/FAKIN/file-info_by-department", "csv$")
  )
  names <- kwb.utils::removeExtension(basename(files))
  names <- kwb.utils::multiSubstitute(names, list(
    "path-info_" = "",
    "(\\d{2})_\\d{4}" = "\\1"
  ))
  stats::setNames(files, names)
}

GLOBALS <- list(max_plots = 5)

selectInput_path_file <- selectInput(
  inputId = "path_file", 
  label = "Load saved paths from",
  choices = get_file_info_files()
)

inlineRadioButtons <- function(...) radioButtons(..., inline = TRUE)

radioInput_separator <- inlineRadioButtons(
  inputId = "separator",
  label = "Column separator",
  choices = c(";", ",")
)

radioInput_type_filter <- inlineRadioButtons(
  inputId = "type_filter",
  label = "Type filter",
  choices = c("all", "file", "directory")
)

textInput_path_filter <- textInput(
  inputId = "path_filter",
  label = "Path filter"
)

sliderInput_max_depth <- sliderInput(
  inputId = "max_depth",
  label = "Levels shown",
  min = 2, max = 5, step = 1, value = 2
)

sliderInput_font_size <- sliderInput(
  inputId = "font_size",
  label = "Font size in pixels",
  min = 7, max = 20, step = 1, value = 10
)

sliderInput_n_levels <- shiny::sliderInput(
  inputId = "n_levels", 
  label = "Levels shown", 
  min = 1, max = 3, step = 1, value = 2
)

sliderInput_n_root_parts <- shiny::sliderInput(
  inputId = "n_root_parts", 
  label = "Root folder levels", 
  min = 1, max = 3, step = 1, value = 2
)

sliderInput_n_plots <- shiny::sliderInput(
  inputId = "n_plots", 
  label = "Number of plots", 
  min = 1, max = GLOBALS$max_plots, value = 2
)

#selectInput_level_1 <- shiny::uiOutput("control_level_1")

radioButtons_treemap_type <- inlineRadioButtons(
  inputId = "treemap_type", 
  label = "Area represents", 
  choices = c("total size" = "size", "total number of files" = "files")
)

radioButtons_group_aesthetics <- inlineRadioButtons(
  inputId = "group_aesthetics",
  label = "Group aesthetics",
  choices = c("colour", "shape")
)

radioButtons_group_by <- inlineRadioButtons(
  inputId = "group_by",
  label = "Group by",
  choices = c("extension", "level-1")
)

tabPanel_table <- tabPanel(
  title = "Table", 
  textOutput("selected_file"),
  DT::dataTableOutput("file_info")
)

tabPanel_sankey <- tabPanel(
  title = "Sankey", 
  fluidRow(
    column(6, sliderInput_max_depth),
    column(6, sliderInput_font_size)
  ),
  networkD3::sankeyNetworkOutput("folder_graph")
)

tabPanel_treemap <- tabPanel(
  title = "Treemap",
  fluidRow(
    column(6, sliderInput_n_levels),
    column(6, radioButtons_treemap_type)
  ),
  shiny::plotOutput("treemap")
)

tabPanel_depth <- tabPanel(
  title = "Files in depth",
  fluidRow(
    column(4, sliderInput_n_root_parts),
    column(4, radioButtons_group_aesthetics),
    column(4, radioButtons_group_by)
  ),
  shiny::plotOutput("depth")
)

tabPanel_multiplot <- tabPanel(
  title = "Test multiplot",
  fluidRow(
    column(4, sliderInput_n_plots)
  ),
  shiny::uiOutput("multiplot")
)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Analyse Paths"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    
    sidebarPanel(
      width = 4,
      selectInput_path_file,
      radioInput_separator,
      radioInput_type_filter,
      textInput_path_filter
      #, selectInput_level_1
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel_table,
        tabPanel_sankey,
        tabPanel_treemap,
        tabPanel_depth,
        tabPanel_multiplot
      )
    )
  )
)

# provide_data -----------------------------------------------------------------
provide_data <- function(x, input)
{
  type <- kwb.utils::selectElements(input, "type_filter")
  pattern <- kwb.utils::selectElements(input, "path_filter")
  
  if (type != "all") {
    x <- x[x$type == type, ]
  }
  
  if (kwb.utils::defaultIfNULL(pattern, "") != "") {
    x <- x[grepl(pattern, x$path), ]
  }
  
  x
}

# get_top_level_paths ----------------------------------------------------------
# get_top_level_paths <- function(input, n_levels = 2)
# {
#   provide_data(input) %>%
#     dplyr::filter(.data$type == "directory") %>%
#     kwb.utils::selectColumns("path") %>%
#     kwb.file::split_into_root_folder_file_extension() %>%
#     dplyr::filter(.data$depth <= n_levels + 1) %>%
#     kwb.utils::selectColumns("folder") %>%
#     remove_empty() %>%
#     unique()
# }

# remove_empty -----------------------------------------------------------------
remove_empty <- function(x)
{
  x[! kwb.utils::isNaOrEmpty(x)]
}

# get_plot_outputs -------------------------------------------------------------
get_plot_outputs <- function(input_n) {
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

# Define server logic ----------------------------------------------------------
server <- function(input, output) {

  file_info_raw <- shiny::reactive({
    kwb.fakin::read_file_info(
      file = kwb.utils::selectElements(input, "path_file"), 
      sep = kwb.utils::selectElements(input, "separator")
    )
  })
    
  output$selected_file <- renderText({
    c("Selected file:", kwb.utils::selectElements(input, "path_file"))
  })

  # output$control_level_1 <- shiny::renderUI({
  #   top_levels <- get_top_level_paths(input)
  #   str(top_levels)
  #   shiny::selectizeInput(
  #     "level_1", 
  #     label = "Filter for top level folder", 
  #     choices = paste0("^", top_levels),
  #     options = list(create = TRUE)
  #   )
  # })
    
  output$file_info <- DT::renderDataTable(
    options = list(scrollX = TRUE), {
      provide_data(x = file_info_raw(), input)
    }
  )
  
  output$folder_graph <- networkD3::renderSankeyNetwork({
    max_depth <- kwb.utils::selectElements(input, "max_depth")
    fontSize <- kwb.utils::selectElements(input, "font_size")
    file_info <- provide_data(x = file_info_raw(), input)
    paths <- kwb.utils::selectColumns(file_info, "path")
    kwb.fakin::plot_path_network(
      paths, max_depth = max_depth, fontSize = fontSize
    )
  })
  
  output$treemap <- shiny::renderPlot({
    kwb.fakin::plot_treemaps_from_path_data(
      provide_data(x = file_info_raw(), input), 
      n_levels = input$n_levels, types = input$treemap_type
    )
  })
  
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

  observe({
    output$multiplot <- renderUI({ 
      get_plot_outputs(input$n_plots)
    })
  })
  
}

# Run the application ----------------------------------------------------------
shinyApp(ui = ui, server = server)
