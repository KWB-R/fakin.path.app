# file_dataUI ------------------------------------------------------------------
file_dataUI <- function(id)
{
  
}

# file_data --------------------------------------------------------------------
file_data <- function(input, output, session)
{
  output$file_info <- DT::renderDataTable(
    options = list(scrollX = TRUE), {
      provide_data(x = file_info_raw(), input)
    }
  )
}
