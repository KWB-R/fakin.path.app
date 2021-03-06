# exploreUI --------------------------------------------------------------------

#' @importFrom jsTree jsTreeOutput
#' @importFrom shiny column fluidRow mainPanel NS sidebarLayout sidebarPanel 
#' @importFrom shiny sliderInput 
#' @keywords internal
exploreUI <- function(id)
{
  ns <- shiny::NS(id)

  tree_output_column <- function(output_id) shiny::column(
    width = 12, 
    jsTree::jsTreeOutput(output_id, height = get_global("plot_height"))
  )
  
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      width = get_global("sidebar_width"),
      shiny::sliderInput(ns("max_depth"), "Maximum depth", 1, 10, 4, 1)
    ),
    shiny::mainPanel(
      width = 12 - get_global("sidebar_width"),
      shiny::fluidRow(
        tree_output_column(ns("jstree1"))
      )
    )
  )
}

# explore ----------------------------------------------------------------------

#' @importFrom jsTree jsTree renderJsTree
#' @importFrom kwb.utils printIf selectColumns
#' @importFrom pathlist depth hide_server
#' @importFrom shiny reactive
#' @importFrom utils head
#' @keywords internal
explore <- function(input, output, session, path_list)
{
  paths <- shiny::reactive({
    
    # Get pathlist object
    pl <- path_list()
    
    stopifnot(inherits(pl, "pathlist"))

    pl@root <- prepare_root_for_jsTree(pathlist::hide_server(pl)@root)

    # Provide file types and depth levels
    types <- kwb.utils::selectColumns(pl@data, "type")

    # Keep only the files. Empty directories would otherwise be shown as files
    keep <- types == "file" & pathlist::depth(pl) <= input$max_depth

    if (! any(keep)) {
      return(".")
    }
    
    # Return the path strings
    cat("Evaluating pl[keep]\n")
    result <- as.character(pl[keep])
    
    kwb.utils::printIf(TRUE, utils::head(result))
    
    result
  })

  output$jstree1 <- jsTree::renderJsTree({
    jsTree::jsTree(paths(), height = "100%")
  }) 
}
