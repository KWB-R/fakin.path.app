# sankeyUI ---------------------------------------------------------------------
sankeyUI <- function(id)
{
  ns <- shiny::NS(id)

  raw_config <- read_slider_config_raw(file = system.file(
    "extdata/sankey_sliders.csv", package = "fakin.path.app"
  ))

  # Give IDs using the namespace function and give default labels
  config <- lapply(stats::setNames(nm = names(raw_config)), function(id) {
    result <- raw_config[[id]]
    result$inputId <- ns(id)
    result$label <- kwb.utils::defaultIfNULL(result$label, id)
    result
  })

  slider_inputs <- unname(lapply(config, do.call, what = shiny::sliderInput))
  
  shiny::sidebarLayout(
    do.call(shiny::sidebarPanel, c(slider_inputs, width = 3)),
    shiny::mainPanel(
      shiny::uiOutput(ns("graph"))
    )
  )
}

# sankey -----------------------------------------------------------------------
sankey <- function(input, output, session, path_list, id = NULL)
{
  default_on_null <- kwb.utils::defaultIfNULL
  
  output$graph_ <- networkD3::renderSankeyNetwork({
    kwb.fakin::plot_path_network(
      paths = path_list(),
      max_depth = input$max_depth,
      nodePadding = default_on_null(input$nodePadding, 10),
      nodeWidth = default_on_null(input$nodeWidth, 15),
      fontSize = default_on_null(input$fontSize, 12),
      method = 2
    )
  })

  output$graph <- shiny::renderUI({
    networkD3::sankeyNetworkOutput(
      if (! is.null(id)) shiny::NS(id)("graph_") else "graph_", 
      height = default_on_null(input$height, "500px"), 
      width = default_on_null(input$width, "100%")
    )
  })
}
