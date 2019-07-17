# sankeyUI ---------------------------------------------------------------------
sankeyUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(6, shiny::sliderInput(
        inputId = ns("max_depth"),
        label = "Levels shown",
        min = 2, max = 5, step = 1, value = 2
      )),
      shiny::column(6, shiny::sliderInput(
        inputId = ns("font_size"),
        label = "Font size in pixels",
        min = 7, max = 20, step = 1, value = 10
      ))
    ),
    networkD3::sankeyNetworkOutput(ns("graph"))
  )
}

# sankey -----------------------------------------------------------------------
sankey <- function(input, output, session, path_list)
{
  output$graph <- networkD3::renderSankeyNetwork({
    kwb.fakin::plot_path_network(
      #paths = kwb.utils::selectColumns(file_info(), "path"),
      paths = path_list(),
      max_depth = kwb.utils::selectElements(input, "max_depth"),
      fontSize = kwb.utils::selectElements(input, "font_size"),
      height = GLOBALS$sankey_height,
      method = 2
    )
  })
}
