#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

get_file_info_files <- function() {
  files <- c(
    kwb.file::dir_full(kwb.fakin::extdata_file(""), "^example_file_info"),
    #kwb.file::dir_full("~/Desktop/Data/FAKIN/file-info_by-department", "csv$")
    kwb.file::dir_full("//medusa/processing/CONTENTS/file-info_by-department/2019-06", "csv$")
  )
  names <- kwb.utils::removeExtension(basename(files))
  names <- kwb.utils::multiSubstitute(names, list(
    "path-info(-ps-1)?_" = "",
    "(\\d{2})_\\d{4}" = "\\1"
  ))
  stats::setNames(files, names)
}

GLOBALS <- list()

selectInput_path_file <- selectInput(
  inputId = "path_file", 
  label = "Load saved paths from",
  choices = get_file_info_files()
)

selectInput_separator <- selectInput(
  inputId = "separator",
  label = "Column separator",
  choices = c(";", ",")
)

selectInput_type_filter <- selectInput(
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
  label = "Maximum depth in graph",
  min = 2, 
  max = 5, 
  value = 2
)

sliderInput_font_size <- sliderInput(
  inputId = "font_size",
  label = "Font size in pixels",
  min = 7,
  max = 20,
  value = 10
)

tabPanel_table <- tabPanel(
  title = "Table", 
  textOutput("selected_file"),
  DT::dataTableOutput("file_info")
)

tabPanel_sankey <- tabPanel(
  title = "Sankey", 
  networkD3::sankeyNetworkOutput("folder_graph")
)

tabPanel_treemap <- tabPanel(
  title = "Treemap",
  shiny::plotOutput("treemap")
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
      selectInput_separator,
      selectInput_type_filter,
      textInput_path_filter,
      sliderInput_max_depth,
      sliderInput_font_size
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel_table,
        tabPanel_sankey,
        tabPanel_treemap
      )
    )
  )
)

provide_data <- function(input) {
  path <- kwb.utils::selectElements(input, "path_file")
  type <- kwb.utils::selectElements(input, "type_filter")
  pattern <- kwb.utils::selectElements(input, "path_filter")
  sep <- kwb.utils::selectElements(input, "separator")
  if (is.null(GLOBALS[["file_info"]])) {
    GLOBALS$file_info <- kwb.fakin::read_file_info(path, sep = sep)
  }
  x <- kwb.utils::selectElements(GLOBALS, "file_info")
  if (type != "all") {
    x <- x[x$type == type, ]
  }
  if (pattern != "") {
    x <- x[grepl(pattern, x$path), ]
  }
  x
}

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$selected_file <- renderText({
    c("Selected file:", kwb.utils::selectElements(input, "path_file"))
  })
  
  output$file_info <- DT::renderDataTable(
    options = list(scrollX = TRUE), {
      provide_data(input)
    }
  )
  
  output$folder_graph <- networkD3::renderSankeyNetwork({
    max_depth <- kwb.utils::selectElements(input, "max_depth")
    fontSize <- kwb.utils::selectElements(input, "font_size")
    file_info <- provide_data(input)
    paths <- kwb.utils::selectColumns(file_info, "path")
    kwb.fakin::plot_path_network(
      paths, max_depth = max_depth, fontSize = fontSize
    )
  })
  
  output$treemap <- shiny::renderPlot({
    kwb.fakin:::plot_treemaps_from_path_data(provide_data(input))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
