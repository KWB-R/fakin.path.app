# Environment used to hold global variables
globals <- new.env()

# set_global -------------------------------------------------------------------
set_global <- function(..., list. = list())
{
  stopifnot(is.list(list.))
  
  assignments <- c(list., list(...))
  
  var_names <- names(assignments)
  
  for (i in seq_along(assignments)) {
    assign(var_names[i], assignments[[i]], envir = globals)
  }
}

# get_global -------------------------------------------------------------------
get_global <- function(name)
{
  get(name, envir = globals)
}

# default_globals --------------------------------------------------------------
default_globals <- function()
{
  list(
    path_database = "",
    sidebar_width = 3,
    plot_height = "550px"
  )
}
