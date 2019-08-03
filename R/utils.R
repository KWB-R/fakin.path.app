# get_environment_vars ---------------------------------------------------------
get_environment_vars <- function(pattern)
{
  var_names <- grep(pattern, names(Sys.getenv()), value = TRUE)
  
  if (length(var_names) == 0) {
    return(list())
  }  
  
  stats::setNames(as.list(Sys.getenv(var_names)), gsub(pattern, "", var_names))
}

# hide_server ------------------------------------------------------------------
hide_server <- function(root, for_js_tree = FALSE)
{
  if (! nzchar(root)) {
    return(ifelse(for_js_tree, ".", ""))
  }
  
  replacements <- c(
    list(
      # Replace real server name with "server"
      "^//[^/]+" = "//server", 
      # Remove dollar character
      "\\$" = ""
    ), 
    if (for_js_tree) list(
      # Remove slashes at start
      "^/+" = "",
      # Replace slash with backslash so that jsTree does not create levels but 
      # keeps the full root path as the root element of the tree
      "/" = "\\\\" 
    )
  )
  
  kwb.utils::multiSubstitute(root, replacements)
}

# inlineRadioButtons -----------------------------------------------------------
inlineRadioButtons <- function(...)
{
  shiny::radioButtons(..., inline = TRUE)
}

# normalise_column_names -------------------------------------------------------
normalise_column_names <- function(x)
{
  kwb.utils::renameColumns(x, list(
    modification_time = "modified",
    last_access = "modified",
    LastWriteTimeUtc = "modified"
  ))
}

# plot_centered_message --------------------------------------------------------
plot_centered_message <- function(text = "Message", cex.text = 1)
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

# run_with_modal ---------------------------------------------------------------
run_with_modal <- function(expr, text = "Loading")
{
  shiny::showModal(shiny::modalDialog(text, footer = NULL))
  result <- eval(expr, envir = -1)
  shiny::removeModal()
  result
}
