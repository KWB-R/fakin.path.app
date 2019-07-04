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

# inlineRadioButtons -----------------------------------------------------------
inlineRadioButtons <- function(...)
{
  radioButtons(..., inline = TRUE)
}
