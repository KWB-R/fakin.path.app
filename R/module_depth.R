# depthUI ----------------------------------------------------------------------
depthUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(4, shiny::sliderInput(
        inputId = ns("n_sample"), label = "Sample size", 
        min = 5000L, max = 50000L, value = 5000L, step = 5000L
      )),
      shiny::column(4, shiny::sliderInput(
        inputId = ns("n_groups"), label = "Number of groups", 
        min = 3L, max = 8L, value = 5L, step = 1L
      ))
    ),
    plotly::plotlyOutput(ns("plot"))
  )
}

# depth ------------------------------------------------------------------------
depth <- function(input, output, session, path_data)
{
  output$plot <- plotly::renderPlotly({

    pl <- path_data()
    
    stopifnot(inherits(pl, "pathlist"))
    
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
    
    kwb.utils::catAndRun("Saving df to file", {
      save(df, file = "~/Desktop/tmp/df.RData")
    })

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
      g + ggplot2::ggtitle(sprintf(
        "Root path: %s", gsub("//medusa", "//server", pl@root)
      ))
    })
    
    plotly::ggplotly(g, tooltip = "label")
  })
}

# prepare_depth_size_data_for_plotly -------------------------------------------
prepare_depth_size_data_for_plotly <- function(pl)
{
  stopifnot(inherits(pl, "pathlist"))
  
  files <- pathlist::filename(pl)
  
  result <- kwb.utils::noFactorDataFrame(
    depth = pl@depths,
    size = pl@data$size,
    file = files,
    extension = kwb.utils::fileExtension(files),
    toplevel = pathlist::toplevel(pl),
    folder = pathlist::folder(pl)
  )
  
  structure(result, root = pl@root)
}

# get_folder_file_size_labels --------------------------------------------------
get_folder_file_size_labels <- function(df)
{
  #df_bak <- kwb.utils::loadObject("~/Desktop/tmp/df.RData", "df")
  #df <- df_bak
  
  sizes <- kwb.utils::selectColumns(df, "size")
  #df[is.na(sizes), ]
  
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
