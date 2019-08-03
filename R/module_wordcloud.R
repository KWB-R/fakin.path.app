# wordcloudUI ------------------------------------------------------------------
wordcloudUI <- function(id)
{
  ns <- shiny::NS(id)
  
  right_border_column <- function(width, output) {
    shiny::column(width, output, align = "center"
      #, style = 'border-right: 1px solid red'
    )
  }
  
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      width = 3,
      shiny::sliderInput(ns("top_n"), "Number of top extensions", 5, 50, 10, 1),
      shiny::sliderInput(ns("min_cex"), "Min. cex", 0.5, 2, 1, 0.1),
      shiny::sliderInput(ns("multiple"), "Max. cex Multiple", 2, 10, 4, 1)
    ),
    
    shiny::mainPanel(
      #style = 'border-right: 1px solid red',
      shiny::fluidRow(
        shiny::column(12, shiny::plotOutput(ns("plot")))
      ),
      shiny::fluidRow(
        right_border_column(4, shiny::tableOutput(ns("table_extensions"))), 
        right_border_column(4, shiny::tableOutput(ns("table_folder_words"))), 
        right_border_column(4, shiny::tableOutput(ns("table_file_words")))
      )
    )
  )

}

# wordcloud --------------------------------------------------------------------
wordcloud <- function(input, output, session, path_list)
{
  dummy_data_frame <- kwb.utils::noFactorDataFrame(
    name = character(), count = integer()
  )
  
  top_n_freq_data <- function(x, top_n = 10L) {
    if (length(x) == 0) {
      return(dummy_data_frame)
    }
    freq_data <- kwb.utils::asNoFactorDataFrame(table(x))
    utils::head(freq_data[order(freq_data$Freq, decreasing = TRUE), ], top_n)
  }
  
  extract_words <- function(x) {
    words <- unlist(strsplit(x, split = "[ _-]+"))
    grep("^[a-zA-Z]{3,}$", words, value = TRUE)
  }

  file_types <- shiny::reactive({
    if (length(path_list()) == 0) {
      character()
    } else {
      kwb.utils::selectColumns(path_list()@data, "type")
    }
  })

  indices_directory <- shiny::reactive({
    which(file_types() == "directory")
  })

  indices_file <- shiny::reactive({
    which(file_types() == "file")
  })
  
  folder_word_freq <- shiny::reactive({

    indices <- indices_directory()

    result <- if (length(indices)) {
      folder_names <- pathlist::filename(path_list()[indices])
      top_n_freq_data(extract_words(folder_names), input$top_n)
    } else {
      dummy_data_frame
    }
    
    stats::setNames(result, c("Word in folder name", "Count"))
  })
 
  file_word_freq <- shiny::reactive({
    
    indices <- indices_file()
    
    result <- if (length(indices)) {
      filenames <- pathlist::filename(path_list()[indices])
      filenames <- kwb.utils::removeExtension(filenames)
      top_n_freq_data(extract_words(filenames), input$top_n)
    } else {
      dummy_data_frame
    }
    stats::setNames(result, c("Word in filename", "Count"))
  })

  extension_freq <- shiny::reactive({

    indices <- indices_file()
    
    result <- if (length(indices)) {
      filenames <- pathlist::filename(path_list()[indices])
      extensions <- kwb.utils::fileExtension(filenames)
      freq_data <- top_n_freq_data(extensions, input$top_n)
      freq_data[kwb.utils::isNaOrEmpty(freq_data[, 1]), 1] <- "<none>"
      freq_data
    } else {
      dummy_data_frame
    }

    stats::setNames(result, c("Filename extension", "Count"))
  })

  output$table_extensions <- shiny::renderTable(extension_freq())
  output$table_folder_words <- shiny::renderTable(folder_word_freq())
  output$table_file_words <- shiny::renderTable(file_word_freq())
  
  output$plot <- shiny::renderPlot({
    old_par <- graphics::par(mfrow = c(1, 3), mar = c(0, 0, 3, 0))
    on.exit(graphics::par(old_par))
    
    min_cex <- input$min_cex
    multiple <- input$multiple
    
    scale <- min_cex * c(multiple, 1)

    freq_functions <- list(extension_freq, folder_word_freq, file_word_freq)               
    titles <- c("Filename Extensions", "Words in Folder Names", "Words in Filenames")
    
    for (i in seq_along(titles)) {
      plot_wordcloud_or_message(
        freq = freq_functions[[i]](), main = titles[i], scale = scale
      )
    }
  })
}

# plot_wordcloud_or_message ----------------------------------------------------
plot_wordcloud_or_message <- function(
  freq, main = "Wordcloud", scale = c(10, 0.5), failure_text = "Nothing to plot"
)
{
  if (nrow(freq)) {
    wordcloud::wordcloud(
      words = freq[, 1], freq = freq[, 2], scale = scale, 
      min.freq = min(freq[, 2]), rot.per = 0, fixed.asp = FALSE
    )
  } else {
    plot_centered_message(failure_text, cex.text = 3)
  }
  
  graphics::title(main, cex.main = 2)
}
