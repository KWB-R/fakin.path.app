# filter_controlsUI ------------------------------------------------------------
filter_controlsUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    radioInput_type_filter,
    textInput_path_filter
  )
}

# filter_controls --------------------------------------------------------------
filter_controls <- function(input, output, session)
{
  
}