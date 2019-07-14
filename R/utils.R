# inlineRadioButtons -----------------------------------------------------------
inlineRadioButtons <- function(...)
{
  shiny::radioButtons(..., inline = TRUE)
}

# remove_empty -----------------------------------------------------------------
remove_empty <- function(x)
{
  x[! kwb.utils::isNaOrEmpty(x)]
}
