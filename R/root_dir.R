# read_root_dirs ---------------------------------------------------------------
read_root_dirs <- function()
{
  file <- root_dir_file()
  
  if (file.exists(file)) {
    readLines(file)
  } else {
    character()
  }
}

# root_dir_file ----------------------------------------------------------------
root_dir_file <- function()
{
  file.path(system.file("extdata", package = "fakin.path.app"), "roots.txt")
}

# write_root_dirs --------------------------------------------------------------
write_root_dirs <- function(root_dirs)
{
  stopifnot(is.character(root_dirs))
  
  writeLines(root_dirs, root_dir_file())
}
