#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

GLOBALS <- list(
  max_plots = 5,
  path_database = if (kwb.utils::user() == "hsonne") {
    "//medusa/processing/CONTENTS/file-info_by-department/2019-07"
  } else {
    "~/Desktop/Data/FAKIN/file-info_by-department"
  }
)
  
library(shiny)
library(magrittr)

kwb.utils::sourceScripts("utils.R")
kwb.utils::sourceScripts("module_sankey.R")
kwb.utils::sourceScripts("module_treemap.R")
kwb.utils::sourceScripts("module_depth.R")
kwb.utils::sourceScripts("module_multiplot.R")


checkbox_remove_common_root <- shiny::checkboxInput(
  inputId = "remove_common_root",
  label = "Remove commmon root", 
  value = TRUE
)

checkbox_keep_first_root <- shiny::checkboxInput(
  inputId = "keep_first_root",
  label = "Keep first root segment", 
  value = FALSE
)

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

# Inputs -----------------------------------------------------------------------

#selectInput_level_1 <- shiny::uiOutput("control_level_1")

tabPanel_table <- tabPanel(
  title = "Table", 
  textOutput("selected_file"),
  DT::dataTableOutput("file_info")
)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Analyse Paths"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    
    sidebarPanel(
      width = 4,
      csv_fileUI("csv", GLOBALS$path_database),
      common_rootUI("common_root"),
      filter_controlsUI("filter_controls")
      #, selectInput_level_1
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel_table,
        tabPanel("Sankey", sankeyUI("sankey")),
        tabPanel("Treemap", treemapUI("treemap")),
        tabPanel("Files in depth", depthUI("depth")),
        tabPanel("Test multiplot", multiplotUI(
          "multiplot", max_plots = GLOBALS$max_plots
        ))
      )
    )
  )
)

# provide_data -----------------------------------------------------------------
provide_data <- function(x, input)
{
  remove_common <- kwb.utils::selectElements(input, "remove_common_root")
  keep_first <- kwb.utils::selectElements(input, "keep_first_root")
  type <- kwb.utils::selectElements(input, "type_filter")
  pattern <- kwb.utils::selectElements(input, "path_filter")
  
  if (remove_common) {
    x$path <- kwb.file::remove_common_root(x$path, n_keep = 0 + keep_first)
  }
  
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

# Define server logic ----------------------------------------------------------
server <- function(input, output)
{
  file_info_raw <- shiny::reactive({
    kwb.fakin::read_file_info(
      file = kwb.utils::selectElements(input, "path_file"), 
      sep = kwb.utils::selectElements(input, "separator")
    )
  })
  
  file_info <- shiny::reactive({
    provide_data(x = file_info_raw(), input)
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
    
  shiny::callModule(file_data, "file_data")
  
  shiny::callModule(sankey, "sankey", file_info = file_info)
  
  shiny::callModule(treemap, "treemap")
  
  shiny::callModule(depth, "depth")  

  shiny::callModule(multiplot, "multiplot")
}

# Run the application ----------------------------------------------------------
shinyApp(ui = ui, server = server)
