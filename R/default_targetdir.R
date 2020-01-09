# default_targetdir ------------------------------------------------------------
default_targetdir <- function()
{
  kwb.utils::createDirectory(file.path(Sys.getenv("HOME"), "pathana-db"))
}
