# commonRootUI -----------------------------------------------------------------
commonRootUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::checkboxInput(
      inputId = ns("remove_common_root"),
      label = "Remove commmon root", 
      value = TRUE
    ),
    shiny::checkboxInput(
      inputId = ns("keep_first_root"),
      label = "Keep first root segment", 
      value = FALSE
    )
  )
}

# commonRoot -------------------------------------------------------------------
commonRoot <- function(input, output, session)
{
  
}