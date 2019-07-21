# exploreUI --------------------------------------------------------------------
exploreUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      width = get_global("sidebar_width"),
      shiny::sliderInput(ns("max_depth"), "Maximum depth", 1, 10, 5, 1)
    ),
    shiny::mainPanel(
      shiny::column(6, jsTree::jsTreeOutput(ns("jstree1"), height = "600px")),
      shiny::column(6, jsTree::jsTreeOutput(ns("jstree2"), height = "600px"))
    )
  )
}

# explore ----------------------------------------------------------------------
explore <- function(input, output, session, path_data)
{
  paths <- shiny::reactive({
    stopifnot(inherits(path_data(), "pathlist"))
    types <- kwb.utils::selectColumns(path_data()@data, "type")
    depths <- path_data()@depths
    keep <- types == "directory" & depths <= input$max_depth
    paste0(as.character(path_data()[keep]), "/.")
  })
  
  output$jstree1 <- jsTree::renderJsTree({
    jsTree::jsTree(paths(), height = "100%")
  }) 
  
  output$jstree2 <- jsTree::renderJsTree({
    jsTree::jsTree(paths(), height = "100%")
  }) 
  
}
