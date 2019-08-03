# fileDataUI -------------------------------------------------------------------
fileDataUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    csvFileUI(ns("csvFile"), get_global("path_database")),
    shiny::textOutput(ns("text")),
    DT::dataTableOutput(ns("table"))
  )
}

# fileData ---------------------------------------------------------------------
fileData <- function(input, output, session)
{
  myCsvFile <- shiny::callModule(csvFile, "csvFile")
  
  file_data <- shiny::reactive({
    
    x <- myCsvFile$content()
    x$type <- factor(x$type, levels = c("directory", "file"))

    x
  })

  filtered_indices <- shiny::reactive(input$table_rows_all)
  
  shiny::observe({
    cat(paste(collapse = "\n", c(
      sprintf("Paths read from %s in\n%s", 
              basename(myCsvFile$file()), 
              dirname(myCsvFile$file())),
      sprintf("Rows: %d, Columns: %d", 
              nrow(myCsvFile$content()), 
              ncol(myCsvFile$content())),
      sprintf("length(all): %d", length(filtered_indices())),
      sprintf("length(current): %d", length(input$table_rows_current)),
      sprintf("length(selected): %d", length(input$table_rows_selected))
    )))
  })
  
  output$text <- shiny::renderText({
    root <- kwb.utils::getAttribute(file_data(), "root")
    if (root != "") {
      sprintf("Paths are relative to: %s", root)
    } else {
      ""
    }
  })
  
  dt_options <- list(scrollX = TRUE, searching = TRUE, lengthChange = FALSE)
  
  output$table <- DT::renderDataTable(
    file_data(), options = dt_options, filter = "top"
  )
  
  shiny::reactive({
    myCsvFile$path_list()[filtered_indices()]
  })
}
