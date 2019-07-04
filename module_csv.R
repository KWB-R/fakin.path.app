# csv_fileUI -------------------------------------------------------------------
csv_fileUI <- function(id, path_database)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    selectInput(
      inputId = ns("path_file"), 
      label = "Load saved paths from",
      choices = get_file_info_files(path_database)
    )
    ,
    radioInput_separator
  )
}

# csv_file ---------------------------------------------------------------------
csv_file <- function()
{
  
}