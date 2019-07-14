# csvFileUI --------------------------------------------------------------------
csvFileUI <- function(id, path_database)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::selectInput(
      inputId = ns("file"), 
      label = "Load saved paths from",
      choices = get_file_info_files(path_database)
    )
    # , inlineRadioButtons(
    #   inputId = ns("sep"),
    #   label = "Column separator",
    #   choices = c(";", ",")
    # )
  )
}

# get_file_info_files ----------------------------------------------------------
get_file_info_files <- function(path_database)
{
  files <- c(
    kwb.file::dir_full(kwb.fakin::extdata_file(""), "^example_file_info"),
    kwb.file::dir_full(path_database, "csv$")
  )
  
  names <- kwb.utils::removeExtension(basename(files))
  names <- kwb.utils::multiSubstitute(names, list(
    "path-info_" = "",
    "(\\d{2})_\\d{4}" = "\\1"
  ))
  
  stats::setNames(files, names)
}

# csvFile ----------------------------------------------------------------------
csvFile <- function(input, output, session, read_function)
{
  file <- shiny::reactive(kwb.utils::selectElements(input, "file"))
  #selected_sep <- shiny::reactive(kwb.utils::selectElements(input, "sep"))
  
  content <- shiny::reactive(read_function(file = file()))
  
  # file_info <- shiny::reactive({
  #   provide_data(x = content(), input)
  # })
  # 
  # output$selected_file <- renderText({
  #   c("Selected file:", kwb.utils::selectElements(input, "path_file"))
  # })

  list(file = file, content = content)
}
