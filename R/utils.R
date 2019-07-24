# inlineRadioButtons -----------------------------------------------------------
inlineRadioButtons <- function(...)
{
  shiny::radioButtons(..., inline = TRUE)
}

# plot_centered_message --------------------------------------------------------
plot_centered_message <- function(text = "Message", cex.text = 3)
{
  graphics::plot(
    NA, NA, xlim = c(0, 1), ylim = c(0, 1), type = "n", axes = FALSE, 
    xlab = "", ylab = ""
  )
  
  graphics::text(0.5, 0.5, text, cex = cex.text)
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
