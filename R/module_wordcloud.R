# wordcloudUI ------------------------------------------------------------------
wordcloudUI <- function(id)
{
  ns <- shiny::NS(id)
  
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      width = 3,
      shiny::sliderInput(ns("top_n"), "Number of top extensions", 5, 50, 10, 1),
      # shiny::sliderInput(ns("scale_1"), "wordcloud: scale[1]", 1, 10, 4, 0.1),
      # shiny::sliderInput(ns("scale_2"), "wordcloud: scale[2]", 1, 10, 0.5, 0.1),
      # shiny::sliderInput(ns("min_freq"), "wordcloud: min.freq", 1, 1000, 3, 1),
      # shiny::sliderInput(ns("max_words"), "wordcloud: max.words", 1, 1000, 1000, 1),
      shiny::sliderInput(ns("size"), "wordcloud2: size", 0, 2, 1, 0.1),
      shiny::sliderInput(ns("minSize"), "wordcloud2: minSize", 0, 2, 0, 0.1),
      shiny::sliderInput(ns("gridSize"), "wordcloud2: gridSize", 0, 2, 0, 0.1)
    ),
    
    shiny::mainPanel(
      #shiny::fluidRow(
        shiny::column(4, shiny::tableOutput(ns("table_extensions")))
        , shiny::column(4, shiny::tableOutput(ns("table_folder_words")))
        , shiny::column(4, shiny::tableOutput(ns("table_file_words")))
        #, shiny::column(2, shiny::plotfOutput(ns("cloud1"))),
        #, shiny::column(6, wordcloud2::wordcloud2Output(ns("cloud2")))
      )
    #)
  )

}

# wordcloud --------------------------------------------------------------------
wordcloud <- function(input, output, session, path_data)
{
  dummy_data_frame <- kwb.utils::noFactorDataFrame(
    name = character(), count = integer()
  )
  
  top_n_freq_data <- function(x, top_n = 10L) {
    if (length(x) == 0) {
      return(dummy_data_frame)
    }
    freq_data <- kwb.utils::asNoFactorDataFrame(table(x))
    head(freq_data[order(freq_data$Freq, decreasing = TRUE), ], top_n)
  }
  
  extract_words <- function(x) {
    words <- unlist(strsplit(x, split = "[ _-]+"))
    grep("^[a-zA-Z]{3,}$", words, value = TRUE)
  }

  folder_word_freq <- shiny::reactive({

    result <- if (length(path_data()) == 0) {
      dummy_data_frame
    } else {
      
      kwb.utils::printIf(TRUE, length(path_data))
      
      types <- kwb.utils::selectColumns(path_data()@data, "type")
      
      kwb.utils::printIf(TRUE, head(types))
      
      indices_directory <- which(types == "directory")
      
      kwb.utils::printIf(TRUE, head(indices_directory))
      
      if (length(indices_directory)) {
        
        kwb.utils::printIf(TRUE, length(indices_directory))
        
        folder_names <- pathlist::filename(path_data()[indices_directory])
        top_n_freq_data(extract_words(folder_names), input$top_n)
      } else {
        dummy_data_frame
      }
    }

    stats::setNames(result, c("Word in directory name", "Count"))
  })
 
  file_word_freq <- shiny::reactive({
    
    result <- if (length(path_data()) == 0) {
      dummy_data_frame
    } else {
      indices_file <- which(path_data()@data$type == "file")
      if (length(indices_file)) {
        filenames <- pathlist::filename(path_data()[indices_file])
        filenames <- kwb.utils::removeExtension(filenames)
        top_n_freq_data(extract_words(filenames), input$top_n)
      } else {
        dummy_data_frame
      }
    }
    stats::setNames(result, c("Word in filename", "Count"))
  })

  extension_freq <- shiny::reactive({

    result <- if (length(path_data()) == 0) {
      dummy_data_frame
    } else {
      extensions <- kwb.utils::fileExtension(pathlist::filename(path_data()))
      print(table(extensions))
      freq_data <- top_n_freq_data(x = extensions, top_n = input$top_n)
      freq_data[kwb.utils::isNaOrEmpty(freq_data[, 1]), 1] <- "<none>"
      freq_data
    }

    stats::setNames(result, c("Filename extension", "Count"))
  })

  output$table_extensions <- shiny::renderTable(extension_freq())
  output$table_folder_words <- shiny::renderTable(folder_word_freq())
  output$table_file_words <- shiny::renderTable(file_word_freq())
  # 
  # # output$cloud1 <- shiny::renderPlot({
  # #   wordcloud::wordcloud(
  # #     extension_freq()$Var1, extension_freq()$Freq,
  # #     scale = c(input$scale_1, input$scale_2), min.freq = input$min_freq,
  # #     max.words = input$max_words
  # #   )
  # # })
  # 
  # output$cloud2 <- wordcloud2::renderWordcloud2({
  #   wordcloud2::wordcloud2(
  #     extension_freq(), size = input$size, minSize = input$minSize,
  #     gridSize = input$gridSize
  #   )
  # })
}
