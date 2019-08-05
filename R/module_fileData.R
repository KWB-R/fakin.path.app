# fileDataUI -------------------------------------------------------------------

#' @importFrom DT dataTableOutput
#' @importFrom shiny NS tagList textOutput
#' @keywords internal
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

#' @importFrom DT renderDataTable
#' @importFrom kwb.utils getAttribute
#' @importFrom shiny callModule observe reactive renderText
#' @keywords internal
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
  
  output$table <- DT::renderDataTable(options = dt_options, filter = "top", {
    DT::datatable(file_data()) %>%
      DT::formatRound(columns = c("size"), digits = 3)
  })
  
  shiny::reactive({
    myCsvFile$path_list()[filtered_indices()]
  })
}
