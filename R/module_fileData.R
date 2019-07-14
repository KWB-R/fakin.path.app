# fileDataUI -------------------------------------------------------------------
fileDataUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::verbatimTextOutput(ns("file")), 
    DT::dataTableOutput(ns("table"))
  )
}

# fileData ---------------------------------------------------------------------
fileData <- function(input, output, session, path, file_data)
{
  # provide_data -----------------------------------------------------------------
  provide_data <- function(x, input)
  {
    remove_common <- kwb.utils::selectElements(input, "remove_common_root")
    keep_first <- kwb.utils::selectElements(input, "keep_first_root")
    type <- kwb.utils::selectElements(input, "type_filter")
    pattern <- kwb.utils::selectElements(input, "path_filter")
    
    if (remove_common) {
      x$path <- kwb.file::remove_common_root(x$path, n_keep = 0 + keep_first)
    }
    
    if (type != "all") {
      x <- x[x$type == type, ]
    }
    
    if (kwb.utils::defaultIfNULL(pattern, "") != "") {
      x <- x[grepl(pattern, x$path), ]
    }
    
    x
  }
  
  
  output$file <- shiny::renderPrint({
    writeLines(
      sprintf("%d paths have been read from the file.", nrow(file_data()))
    )
  })
  
  output$table <- DT::renderDataTable(
    options = list(scrollX = TRUE), {
      file_data()
    }
  )
}
