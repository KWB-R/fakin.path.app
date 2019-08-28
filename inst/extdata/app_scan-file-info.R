# default_targetdir ------------------------------------------------------------
default_targetdir <- function()
{
  kwb.utils::createDirectory(file.path(Sys.getenv("HOME"), "pathana-db"))
}

# Define elements of the user interface ----------------------------------------
button_browse <- shinyFiles::shinyDirButton(
  "browse", "Add root directory...", "Select a root directory"
)

button_remove <- shiny::actionButton(
  "remove", "Remove selected root directories"
)

button_scan <- shiny::actionButton(
  "scan", "Scan root directories"
)

width <- "400px"

input_root_dirs <- shiny::selectInput(
  "root_dirs", label = NULL, width = width, 
  choices = fakin.path.app:::read_root_dirs(), 
  multiple = TRUE, selectize = FALSE
)

input_target_dir <- shiny::textInput(
  "targetdir", label = NULL, value = default_targetdir(), width = width
)

button_browse_target <- shinyFiles::shinyDirButton(
  "browse_target", "Change output directory...", "Select the output directory"
)

# Define the user interface ----------------------------------------------------
ui <- shiny::fluidPage(
  shinyjs::useShinyjs(),
  shiny::tags$head(shiny::tags$script(src = "message-handler.js")),
  h3("1. Define root directories"),
  input_root_dirs,
  shiny::fluidRow(column(width = 12, button_browse, button_remove)),
  h3("2. Define output directory"),
  shinyjs::disabled(input_target_dir),
  button_browse_target,
  h3("3. Scan root directories"),
  button_scan
)

# Server Logic -----------------------------------------------------------------
server <- function(input, output, session) {

  # Helper function to update the list of root directories  
  update_root_dirs <- function(root_dirs) {
    fakin.path.app:::write_root_dirs(root_dirs)
    shiny::updateSelectInput(session, "root_dirs", choices = root_dirs)
  }

  # Volumes required as start paths for shinyDirChoose()
  volumes <- shinyFiles::getVolumes()

  # Let the user choose a new root directory if the browse button is clicked
  shinyFiles::shinyDirChoose(
    input, "browse", roots = volumes, session = session
  )

  shinyFiles::shinyDirChoose(
    input, "browse_target", roots = volumes, session = session
  )
  
  # Update the list of root directories if a new path was selected
  observeEvent(input$browse, {
    new_dir <- shinyFiles::parseDirPath(volumes, input$browse)
    if (length(new_dir) == 0) {
      return()
    }
    root_dirs <- fakin.path.app:::read_root_dirs()
    root_dirs <- sort(unique(c(root_dirs, new_dir)))
    update_root_dirs(root_dirs)
  })

  # Update the target directory if a new path was selected
  observeEvent(input$browse_target, {
    new_dir <- shinyFiles::parseDirPath(volumes, input$browse_target)
    if (length(new_dir) == 0) {
      return()
    }
    shiny::updateTextInput(session, "targetdir", value = new_dir)
  })

  # Update the list of root directories if the "remove" button is clicked
  observeEvent(input$remove, {
    root_dirs <- fakin.path.app:::read_root_dirs()
    root_dirs <- setdiff(root_dirs, input$root_dirs)
    update_root_dirs(root_dirs)
  })

  # Run the scanning of the root directories  
  observeEvent(input$scan, {
    paths <- fakin.path.app:::read_root_dirs()
    output_dir <- input$targetdir

    if (! file.exists(output_dir)) {
      text <- paste(
        "The output directory does not exist!", 
        "Please change the output directory."
      )
      shiny::showModal(shiny::modalDialog(text))
      return()
    } 
    
    is_ok <- file.exists(paths)
    
    if (any(! is_ok)) {
      
      text <- shiny::HTML(paste(
        "The following root directories do not exist:<br><br>\n",
        paste(paths[! is_ok], collapse = "<br>\n"),
        "<br><br>\nPlease remove non-existing root directories from the list."
      ))
      
      shiny::showModal(shiny::modalDialog(text))
      return() 
    }

    for (root_dir in paths[is_ok]) {

      fakin.path.app:::run_with_modal(
        text = paste("Scanning files below", root_dir), {
          kwb.fakin::get_and_save_file_info(
            root_dir, output_dir, check_dirs = TRUE, format = "%Y-%m-%d"
          )
        }
      )
    }
    
    shiny::showModal(shiny::modalDialog(
      shiny::HTML("The following files can now be inspected:<br><br>\n"),
      shiny::HTML(paste(
        dir(output_dir, pattern = as.character(Sys.Date())),
        collapse = "<br>\n"
      ))
    ))
  })
}

# Run the app
shiny::shinyApp(ui, server)
