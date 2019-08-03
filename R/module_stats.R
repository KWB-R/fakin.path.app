# statsUI ----------------------------------------------------------------------
statsUI <- function(id)
{
  ns <- shiny::NS(id)
  
  header_fun <- shiny::h4
  
  shiny::tagList(
    #header_fun("Compliance"),
    shiny::tableOutput(ns("compliance")),
    #header_fun("Longest paths"),
    shiny::tableOutput(ns("longest_paths")),
    #header_fun("Longest filenames"),
    shiny::tableOutput(ns("longest_files")),
    #header_fun("Longest folder names"),
    shiny::tableOutput(ns("longest_folders")),
    #header_fun("Biggest files"),
    shiny::tableOutput(ns("biggest_files"))
  )
}

# stats ------------------------------------------------------------------------
stats <- function(input, output, session, path_list)
{
  path_summary <- shiny::reactive({
    if (! is.null(path_list())) {
      kwb.fakin:::get_path_summary(path_list(), n = 5)
    } # else NULL
  })
  
  pattern_counts <- shiny::reactive({
    filenames <- pathlist::filename(path_list())
    patterns <- c(
      "^(Dok1|Mappe1|Pr.sentation1)", "^Kopie von", "gdalwmscache", 
      "win-library", "^README\\.txt$", "^README\\.yml$"
    )
    kwb.utils::noFactorDataFrame(
      Indicator = sprintf("Number of files/folders matching '%s'", patterns),
      Value = lengths(lapply(patterns, grep, filenames))
    )
  })
  
  to_path_length_table <- function(name, xx) {
    stats::setNames(data.frame(xx, nchar(xx)), c(name, "length"))
  }
  
  output$compliance <- shiny::renderTable({
    indicators <- kwb.utils::noFactorDataFrame(
      Indicator = "File/folder name quality",
      Value = sprintf("%0.1f %%", path_summary()$percentage_good_filename)
    )
    rbind(indicators, pattern_counts())
  })
  
  output$longest_paths <- shiny::renderTable({
    to_path_length_table("Longest paths", path_summary()$longest_path)
  })
  
  output$longest_files <- shiny::renderTable({
    to_path_length_table("Longest filenames", path_summary()$longest_file)
  })
  
  output$longest_folders <- shiny::renderTable({
    to_path_length_table("Longest folder names", path_summary()$longest_folder)
  })
  
  output$biggest_files <- shiny::renderTable({
    stats::setNames(nm = c("Biggest files", "Size in MiB"), data.frame(
      path_summary()$biggest_file,
      kwb.utils::getAttribute(path_summary()$biggest_file, "sizes")
    ))
  })

}
