# bytes_to_mib -----------------------------------------------------------------
bytes_to_mib <- function(x)
{
  x / 2^20
}

# cat_elapsed ------------------------------------------------------------------
cat_elapsed <- function(time_info)
{
  cat("Elapsed:", time_info["elapsed"], "\n")
}

# dir_or_stop ------------------------------------------------------------------
dir_or_stop <- function(path, pattern)
{
  if (! nzchar(path)) {
    return(NULL)
  }
  
  if (! dir.exists(path)) {
    stop("No such directory: '", path, "'", call. = FALSE)
  }
  
  dir(path, pattern, full.names = TRUE)
}

# extdata_file -----------------------------------------------------------------
extdata_file <- function(...)
{
  system.file("extdata", ..., package = "fakin.path.app")
}

# get_environment_vars ---------------------------------------------------------
get_environment_vars <- function(pattern)
{
  var_names <- grep(pattern, names(Sys.getenv()), value = TRUE)
  
  if (length(var_names) == 0) {
    return(list())
  }  
  
  stats::setNames(as.list(Sys.getenv(var_names)), gsub(pattern, "", var_names))
}

# grepl_bytes ------------------------------------------------------------------
grepl_bytes <- function(...)
{
  grepl(..., useBytes = TRUE)
}

# prepare_root_for_jsTree ------------------------------------------------------
prepare_root_for_jsTree <- function(root)
{
  if (! nzchar(root)) {
    return(".")
  }
  
  replacements <- list(
    # Remove slashes at start
    "^/+" = "",
    # Replace slash with backslash so that jsTree does not create levels but 
    # keeps the full root path as the root element of the tree
    "/" = "\\\\" 
  )
  
  kwb.utils::multiSubstitute(root, replacements)
}

# inlineRadioButtons -----------------------------------------------------------
inlineRadioButtons <- function(...)
{
  shiny::radioButtons(..., inline = TRUE)
}

# left_substring_equals --------------------------------------------------------

#' Is Left Substring of X Equal To Y?
#'
#' @param x String of which the left part is compared with \code{y}
#' @param y String to be compared with the left part of \code{x}
#'
left_substring_equals <- function(x, y)
{
  stopifnot(is.character(x), is.character(y))
  
  substr(x, 1, nchar(y)) == y
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

# read_csv_fread ---------------------------------------------------------------
read_csv_fread <- function(file, sep = ";", fileEncoding = NULL, ...)
{
  fileEncoding <- kwb.utils::defaultIfNULL(fileEncoding, "unknown")
  
  kwb.utils::catAndRun(
    sprintf("Reading '%s' with data.table::fread()", file),
    as.data.frame(data.table::fread(
      file = file, sep = sep, encoding = fileEncoding, ...
    ))
  )
}

# read_slider_config_raw -------------------------------------------------------
read_slider_config_raw <- function(file)
{
  raw_config <- utils::read.table(
    file, header = TRUE, sep = ";", stringsAsFactors = FALSE, comment.char = "#"
  )
  
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

# stop_ ------------------------------------------------------------------------
stop_ <- function(...)
{
  stop(..., call. = FALSE)
}

# to_top_n ---------------------------------------------------------------------
to_top_n <- function(x, n = 5, other = "<other>")
{
  x <- tolower(x)
  
  decreasingly_sorted_table <- function(xx) sort(table(xx), decreasing = TRUE)
  
  top_n <- names(decreasingly_sorted_table(x)[seq_len(n)])
  
  x[! x %in% top_n] <- other
  
  freqs <- decreasingly_sorted_table(x)
  
  labels <- sprintf("%s (%d)", names(freqs), as.integer(freqs))
  
  factor(x, levels = names(freqs), labels = labels)
}

# write_csv --------------------------------------------------------------------

#' Write Data Frame to CSV File
#'
#' @param data data frame
#' @param file path to CSV file to be written
#' @param sep column separator
#' @param version determines which function to use for writing the CSV file
#'   1: \code{\link[utils]{write.table}}, 2: \code{\link[data.table]{fwrite}}
#' @param \dots further arguments passed to \code{\link[utils]{write.table}} or
#'   \code{\link[data.table]{fwrite}}
#' @export
#'
write_csv <- function(data, file, sep = ";", version = 2, ...)
{
  message_string <- function(fun) sprintf("Writing to '%s' with %s", file, fun)
  
  if (version == 1) {
    
    kwb.utils::catAndRun(
      message_string("utils::write.table()"),
      utils::write.table(
        data, file, row.names = FALSE, col.names = TRUE, sep = sep, na = "",
        ...
      )
    )
    
  } else if (version == 2) {
    
    kwb.utils::catAndRun(
      message_string("data.table::fwrite()"),
      data.table::fwrite(data, file, sep = sep, ...)
    )
    
  } else {
    
    stop_(
      "Invalid version (", version, "). Possible values are:\n",
      "  1 - use write.table() or\n",
      "  2 - use data.table::fwrite().\n"
    )
  }
}
