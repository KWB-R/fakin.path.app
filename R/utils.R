# inlineRadioButtons -----------------------------------------------------------
inlineRadioButtons <- function(...)
{
  shiny::radioButtons(..., inline = TRUE)
}

# read_slider_config_raw -------------------------------------------------------
read_slider_config_raw <- function(file)
{
  raw_config <- kwb.fakin::read_csv(file, version = 1, comment.char = "#")
  raw_config$name <- kwb.utils::toFactor(raw_config$name)
  raw_config <- split(raw_config, raw_config$name)
  lapply(raw_config, kwb.utils::removeColumns, "name")
}

# remove_empty -----------------------------------------------------------------
remove_empty <- function(x)
{
  x[! kwb.utils::isNaOrEmpty(x)]
}
