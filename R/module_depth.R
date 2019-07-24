# depthUI ----------------------------------------------------------------------
depthUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::fluidRow(
      # shiny::column(4, shiny::sliderInput(
      #   inputId = ns("n_root_parts"),
      #   label = "Root folder levels",
      #   min = 1, max = 3, step = 1, value = 2
      # )),
      # shiny::column(4, inlineRadioButtons(
      #   inputId = ns("group_aesthetics"),
      #   label = "Group aesthetics",
      #   choices = c("colour", "shape")
      # )),
      # shiny::column(4, inlineRadioButtons(
      #   inputId = ns("group_by"),
      #   label = "Group by",
      #   choices = c("top-level" = "level-1", "extension")
      # )),
      shiny::column(4, shiny::sliderInput(
        inputId = ns("n_sample"), label = "Sample size", 
        min = 5000L, max = 50000L, value = 5000L, step = 5000L
      )),
      shiny::column(4, shiny::sliderInput(
        inputId = ns("n_groups"), label = "Number of groups", 
        min = 3L, max = 8L, value = 5L, step = 1L
      ))
    ),
    #shiny::plotOutput(ns("plot"))
    plotly::plotlyOutput(ns("plot"))
  )
  # shiny::sidebarLayout(
  #   shiny::sidebarPanel(
  #     width = get_global("sidebar_width"),
  #     shiny::sliderInput(
  #       inputId = ns("n_root_parts"), 
  #       label = "Root folder levels", 
  #       min = 1, max = 3, step = 1, value = 2
  #     ),
  #     shiny::radioButtons(
  #       inputId = ns("group_aesthetics"),
  #       label = "Group aesthetics",
  #       choices = c("colour", "shape")
  #     ),
  #     shiny::radioButtons(
  #       inputId = ns("group_by"),
  #       label = "Group by",
  #       choices = c("extension", "level-1")
  #     )
  #   ), 
  #   shiny::mainPanel(
  #     shiny::plotOutput(ns("plot"))
  #   )
  # )
}

# depth ------------------------------------------------------------------------
depth <- function(input, output, session, path_data)
{
  # file_data <- shiny::reactive({
  #   
  #   stopifnot(inherits(path_data(), "pathlist"))
  #   
  #   cbind.data.frame(
  #     path_data()@data, 
  #     path = as.character(path_data()), 
  #     stringsAsFactors = FALSE
  #   )
  # })
  
  #output$plot <- shiny::renderPlot({
  output$plot <- plotly::renderPlotly({
    #   prepared_data <- kwb.fakin:::prepare_for_scatter_plot2(
    #     file_data = path_data()
    #   )
    #   
    #   kwb.fakin:::plot_file_size_in_depth(
    #     df = prepared_data,
    #     main = "Total",
    #     group_aesthetics = input$group_aesthetics,
    #     group_by = input$group_by
    #   )
    # })
    
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
