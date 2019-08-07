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
  
  output$text <- shiny::renderText({
    root <- kwb.utils::getAttribute(file_data(), "root")
    if (root != "") {
      sprintf("Paths are relative to: %s", root)
    } else {
      ""
    }
  })
  
  dt_options <- list(scrollX = TRUE, searching = TRUE, lengthChange = FALSE)

  output$table <- DT::renderDataTable({
    DT::datatable(file_data(), options = dt_options, filter = "top") %>%
      DT::formatRound(columns = c("size"), digits = 3)
  })
  
  shiny::reactive({
    myCsvFile$path_list()[filtered_indices()]
  })
}
