# wordcloudUI ------------------------------------------------------------------
wordcloudUI <- function(id)
{
  ns <- shiny::NS(id)
  
  # shiny::sidebarLayout(
  #   shiny::sidebarPanel(
  #   ),
  #   shiny::mainPanel(
      shiny::plotOutput(ns("extensions"), width = "500px", height = "500px")
  #   )
  # )
}

# wordcloud --------------------------------------------------------------------
wordcloud <- function(input, output, session, path_data)
{
  output$extensions <- shiny::renderPlot({
    freq <- table(path_data()@extension())
    wordcloud::wordcloud(names(freq), unname(freq))
  }) 
}
