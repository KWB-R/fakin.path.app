# statsUI ----------------------------------------------------------------------
statsUI <- function(id)
{
  ns <- shiny::NS(id)
  
  header_fun <- shiny::h4
  
  shiny::tagList(
    header_fun("Compliance"),
    shiny::textOutput(ns("compliance")),
    header_fun("Longest paths"),
    shiny::tableOutput(ns("longest_paths")),
    header_fun("Longest filenames"),
    shiny::tableOutput(ns("longest_files")),
    header_fun("Longest folder names"),
    shiny::tableOutput(ns("longest_folders")),
    header_fun("Biggest files"),
    shiny::tableOutput(ns("biggest_files"))
  )
}

# stats ------------------------------------------------------------------------
stats <- function(input, output, session, path_data)
{
  path_summary <- shiny::reactive({
    if (! is.null(path_data())) {
      kwb.fakin:::get_path_summary(path_data(), n = 5)      
    } # else NULL
  })
  
  to_path_length_table <- function(name, xx) {
    stats::setNames(data.frame(xx, nchar(xx)), c(name, "length"))
  }
  
  output$compliance <- shiny::renderPrint({
    cat(sprintf(
      "File/folder name quality: %0.1f %%", 
      path_summary()$percentage_good_filename
    ))
  })
  
  output$longest_paths <- shiny::renderTable({
    to_path_length_table("path", path_summary()$longest_path)
  })
  
  output$longest_files <- shiny::renderTable({
    to_path_length_table("file", path_summary()$longest_file)
  })
  
  output$longest_folders <- shiny::renderTable({
    to_path_length_table("folder", path_summary()$longest_folder)
  })
  
  output$biggest_files <- shiny::renderTable({
    data.frame(
      file = path_summary()$biggest_file,
      size_mib = kwb.utils::getAttribute(path_summary()$biggest_file, "sizes")
    )
  })

}
