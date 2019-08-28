# server_app_scan --------------------------------------------------------------
server_app_scan <- function(input, output, session) {

  # Helper function to update the list of root directories  
  update_root_dirs <- function(root_dirs) {
    write_root_dirs(root_dirs)
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
  shiny::observeEvent(input$browse, {
    new_dir <- shinyFiles::parseDirPath(volumes, input$browse)
    if (length(new_dir) == 0) {
      return()
    }
    root_dirs <- read_root_dirs()
    root_dirs <- sort(unique(c(root_dirs, new_dir)))
    update_root_dirs(root_dirs)
  })

  # Update the target directory if a new path was selected
  shiny::observeEvent(input$browse_target, {
    new_dir <- shinyFiles::parseDirPath(volumes, input$browse_target)
    if (length(new_dir) == 0) {
      return()
    }
    shiny::updateTextInput(session, "targetdir", value = new_dir)
  })

  # Update the list of root directories if the "remove" button is clicked
  shiny::observeEvent(input$remove, {
    root_dirs <- read_root_dirs()
    root_dirs <- setdiff(root_dirs, input$root_dirs)
    update_root_dirs(root_dirs)
  })

  # Run the scanning of the root directories  
  shiny::observeEvent(input$scan, {
    paths <- read_root_dirs()
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

      run_with_modal(
        text = paste("Scanning files below", root_dir), {
          kwb.fakin::get_and_save_file_info(
            root_dir, output_dir, check_dirs = TRUE, format = "%Y-%m-%d",
            fail = FALSE
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

# run_app_scan -----------------------------------------------------------------

#' Run the App that Stores File Information to CSV Files
#' 
#' @export
run_app_scan <- function()
{
  # Run the app
  shiny::shinyApp(ui = get_ui_app_scan(), server = server_app_scan)
}
