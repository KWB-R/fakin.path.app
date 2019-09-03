# get_ui_app_scan --------------------------------------------------------------
get_ui_app_scan <- function(width = "400px")
{
  # Define elements of the user interface
  button_browse <- shinyFiles::shinyDirButton(
    "browse", "Add root directory...", "Select a root directory"
  )
  
  button_remove <- shiny::actionButton(
    "remove", "Remove selected root directories"
  )
  
  button_scan <- shiny::actionButton(
    "scan", "Scan root directories"
  )
  
  input_root_dirs <- shiny::selectInput(
    "root_dirs", label = NULL, width = width, 
    choices = read_root_dirs(), 
    multiple = TRUE, selectize = FALSE
  )
  
  input_target_dir <- shiny::textInput(
    "targetdir", label = NULL, value = default_targetdir(), width = width
  )
  
  button_browse_target <- shinyFiles::shinyDirButton(
    "browse_target", "Change output directory...", "Select the output directory"
  )
  
  # Define the user interface
  shiny::fluidPage(
    shinyjs::useShinyjs(),
    shiny::tags$head(shiny::tags$script(src = "message-handler.js")),
    htmltools::h3("1. Define root directories"),
    input_root_dirs,
    shiny::fluidRow(column(width = 12, button_browse, button_remove)),
    htmltools::h3("2. Define output directory"),
    shinyjs::disabled(input_target_dir),
    button_browse_target,
    htmltools::h3("3. Scan root directories"),
    button_scan
  )
}

# default_targetdir ------------------------------------------------------------
default_targetdir <- function()
{
  kwb.utils::createDirectory(file.path(Sys.getenv("HOME"), "pathana-db"))
}
