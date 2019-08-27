default_outputdir <- function()
{
  kwb.utils::createDirectory(file.path(Sys.getenv("HOME"), "pathana-db"))
}

ui <- shiny::fluidPage(
  
  shiny::tags$head(shiny::tags$script(src = "message-handler.js")),
  
  shiny::textAreaInput("startpaths", "Start paths", value = kwb.utils::desktop(), 
                       rows = 4),
  
  shiny::textInput("outputdir", "Output directory", value = default_outputdir()),
  
  shiny::actionButton("do", "Scan")
)

server <- function(input, output, session) {
  
  observeEvent(input$do, {
    
    # Get inputs
    paths <- strsplit(input$startpaths, split = "\r?\n")[[1]]
    output_dir <- input$outputdir
    
    is_ok <- file.exists(paths)
    
    if (any(! is_ok)) {
      message("The following paths are skipped because the do not exist:\n- ",
              kwb.utils::stringList(paths[! is_ok], collapse = "\n- "))
    }
    
    root_dirs <- paths[is_ok]
    
    for (root_dir in root_dirs) {
      
      fakin.path.app:::run_with_modal(
        text = paste("Scanning files below", root_dir), {
          kwb.fakin::get_and_save_file_info(
            root_dir, output_dir, check_dirs = TRUE, format = "%Y-%m-%d"
          )
        }
      )
    }
  })
}

shiny::shinyApp(ui, server)

