# get_global -------------------------------------------------------------------
get_global <- function(name)
{
  user <- try(kwb.utils::user())
  
  if (inherits(user, "try-error")) {
    user <- "unknown"
  }
  
  globals <- list(
    max_plots = 5,
    path_database = if (user == "hsonne") {
      "//medusa/processing/CONTENTS/file-info_by-department/2019-07"
    } else {
      "~/Desktop/Data/FAKIN/file-info_by-department"
    },
    sidebar_width = 3,
    plot_height = "550px"
  )
  
  value <- options()[[paste0("fakin.path.app.", name)]]
  
  if (is.null(value)) {
    kwb.utils::selectElements(globals, name)
  } else {
    value
  }
}
