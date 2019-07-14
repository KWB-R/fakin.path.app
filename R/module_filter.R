# filterControlsUI -------------------------------------------------------------
filterControlsUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    inlineRadioButtons(
      inputId = ns("type_filter"),
      label = "Type filter",
      choices = c("all", "file", "directory")
    ),
    shiny::textInput(
      inputId = ns("path_filter"),
      label = "Path filter"
    )
  )
}

# filterControls ---------------------------------------------------------------
filterControls <- function(input, output, session)
{
  
}