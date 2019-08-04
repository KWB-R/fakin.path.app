# depthUI ----------------------------------------------------------------------

#' @importFrom plotly plotlyOutput
#' @importFrom shiny mainPanel NS sidebarLayout sidebarPanel sliderInput 
#' @keywords internal
depthUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      width = get_global("sidebar_width"),
      shiny::sliderInput(
        inputId = ns("n_sample"), label = "Sample size", 
        min = 2500L, max = 50000L, value = 2500L, step = 2500L
      ),
      shiny::sliderInput(
        inputId = ns("n_groups"), label = "Number of groups", 
        min = 3L, max = 8L, value = 5L, step = 1L
      )
    ),
    shiny::mainPanel(
      plotly::plotlyOutput(ns("plot"), height = get_global("plot_height"))
    )
  )
}

# depth ------------------------------------------------------------------------

#' @importFrom ggplot2 ggtitle
#' @importFrom kwb.file split_paths
#' @importFrom kwb.utils catAndRun checkForMissingColumns
#' @importFrom pathlist as.list pathlist
#' @importFrom plotly ggplotly renderPlotly
#' @importFrom shiny showNotification
#' @keywords internal
depth <- function(input, output, session, path_list)
{
  output$plot <- plotly::renderPlotly({

    pl <- path_list()
    
    stopifnot(inherits(pl, "pathlist"))

    kwb.utils::checkForMissingColumns(pl@data, c("type", "size"))

    # Filter for files, discarding directories    
    cat("Evaluating pl[pl@data$type == 'file']\n")
    pl <- pl[pl@data$type == "file"]
    
    if (length(pl) == 0) {
      shiny::showNotification(duration = 5, paste0(
        "No files selected.\n", 
        "You may need to remove a filter on type = 'directory'"
      ))
      return()
    }
    
    # Reinitialise the pathlist object so that the root is recalculated
    pl <- pathlist::pathlist(segments = pathlist::as.list(pl), data = pl@data)
    
    n_sample <- input$n_sample
    n_available <- length(pl)
    
    if (n_available > n_sample) {
      
      pl <- kwb.utils::catAndRun(
        sprintf("sampling %d out of %d records...", n_sample, n_available),
        pl[sample(seq_len(n_available), n_sample)]
      )
    }
    
    df <- kwb.utils::catAndRun(
      "Preparing depth-size data for plotly",
      prepare_depth_size_data_for_plotly(pl)
    )
    
    labels <- kwb.utils::catAndRun("Creating labels", {
      get_folder_file_size_labels(df)
    })
    
    # Set missing sizes to 1 GiB (label will be "not available!")
    df$size[is.na(df$size)] <- 1024

    kwb.utils::catAndRun("Setting columns 'group', 'label', 'depth'", {
      df$group <- kwb.fakin:::to_top_n(df$toplevel, n = input$n_groups - 1L)
      df$label <- labels
      df$depth <- df$depth + length(kwb.file::split_paths(pl@root)[[1]]) - 1L
    })
        
    g <- kwb.utils::catAndRun("Creating gg-plot object", {
      kwb.fakin:::plot_file_size_in_depth_gg(df)
    })
    
    g <- kwb.utils::catAndRun("Setting the plot title", {
      g + ggplot2::ggtitle(sprintf("Root path: %s", pl@root))
    })
    
    plotly::ggplotly(g, tooltip = "label")
  })
}

# prepare_depth_size_data_for_plotly -------------------------------------------

#' @importFrom kwb.utils fileExtension noFactorDataFrame
#' @importFrom pathlist depth filename folder toplevel
#' @keywords internal
prepare_depth_size_data_for_plotly <- function(pl)
{
  stopifnot(inherits(pl, "pathlist"))
  
  files <- pathlist::filename(pl)
  
  result <- kwb.utils::noFactorDataFrame(
    depth = pathlist::depth(pl),
    size = pl@data$size,
    file = files,
    extension = kwb.utils::fileExtension(files),
    toplevel = pathlist::toplevel(pl),
    folder = pathlist::folder(pl)
  )
  
  structure(result, root = pl@root)
}

# get_folder_file_size_labels --------------------------------------------------

#' @importFrom gdata humanReadable
#' @importFrom kwb.utils selectColumns
#' @keywords internal
get_folder_file_size_labels <- function(df)
{
  sizes <- kwb.utils::selectColumns(df, "size")

  size_text <- rep("not available!", nrow(df))
  ok <- ! is.na(sizes)
  size_text[ok] <- gdata::humanReadable(
    sizes[ok] * 2^20, justify = c("none", "none")
  )
  
  sprintf(
    "Top-level: %s\nFolder: %s\nFile: %s\nSize: %s", 
    kwb.utils::selectColumns(df, "toplevel"), 
    kwb.utils::selectColumns(df, "folder"), 
    kwb.utils::selectColumns(df, "file"), 
    size_text
  )
}
