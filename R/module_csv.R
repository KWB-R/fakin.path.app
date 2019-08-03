# csvFileUI --------------------------------------------------------------------
csvFileUI <- function(id, path_database)
{
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::selectInput(
      inputId = ns("file"), 
      label = "Load saved paths from",
      choices = get_file_info_files(path_database)
    )
  )
}

# get_file_info_files ----------------------------------------------------------
get_file_info_files <- function(path_database)
{
  files <- c(
    kwb.file::dir_full(kwb.fakin::extdata_file(""), "^example_file_info"),
    kwb.file::dir_full(path_database, "csv$")
  )
  
  names <- kwb.utils::removeExtension(basename(files))
  names <- kwb.utils::multiSubstitute(names, list(
    "path-info(-ps-1)?_" = "",
    "(\\d{2})_\\d{4}" = "\\2"
  ))
  
  stats::setNames(files, names)
}

# csvFile ----------------------------------------------------------------------
csvFile <- function(input, output, session, read_function)
{
  csv_file <- shiny::reactive({
    input$file
  })
  
  rds_file <- shiny::reactive({
    gsub("\\.csv$", ".rds", csv_file())
  })
  
  rds_file_exists <- shiny::reactive({
    result <- file.exists(rds_file())
    cat("rds file ", rds_file(), "exists:", result, "\n")
    result
  })
  
  raw_content <- shiny::reactive({
    
    if (rds_file_exists()) {
      return(function(...) NULL)
    } 

    x <- run_with_modal(
      text = paste("Reading", basename(csv_file())), {
      kwb.fakin::read_file_paths(csv_file())
    })
    
    x <- kwb.utils::renameColumns(x, list(
      modification_time = "modified", 
      last_access = "modified",
      LastWriteTimeUtc = "modified"
    ))
    kwb.utils::selectColumns(x, c("path", "type", "size", "modified"))
  })

  rds_content <- shiny::reactive({
    if (rds_file_exists()) {
      run_with_modal(
        text = paste("Loading", basename(rds_file())), {
        readRDS(rds_file())
      })
    } else {
      NULL
    }
  })
  
  path_list <- shiny::reactive({
    
    if (! is.null(rds_content())) {
      return(rds_content()$path_list)
    }

    pl <- run_with_modal(
      text = "Providing table data", {
      pathlist::pathlist(
        paths = raw_content()$path, 
        data = raw_content()[, c("type", "size")]
      )
    })
    
    pl@root <- hide_server(pl@root)
    
    pl
  })
  
  content <- shiny::reactive({
    
    if (! is.null(rds_content())) {
      return(rds_content()$content)
    }
    
    x <- raw_content()
    dates <- as.Date(as.POSIXct(x$modified, "%Y-%m-%dT%H:%M:%S", tz = "UTC"))
    x$modified <- dates
    x$size <- round(x$size, 6)
    x$toplevel <- factor(pathlist::toplevel(path_list()))
    x$folder <- pathlist::folder(path_list())
    x$filename <- pathlist::filename(path_list())
    x$extension <- ""
    is_file <- x$type == "file"
    x$extension[is_file] <- kwb.utils::fileExtension(x$filename[is_file])
    x$extension <- factor(x$extension)
    x$depth <- pathlist::depth(path_list())

    x <- kwb.utils::moveColumnsToFront(kwb.utils::removeColumns(x, "path"), c(
      "toplevel", "folder", "filename", "extension"
    ))
    
    content <- structure(x, root = path_list()@root)

    rds_content <- list(content = content, path_list = path_list())
    
    run_with_modal(
      text = paste("Caching data in", basename(rds_file())), {
      saveRDS(rds_content, file = rds_file())
    })
    
    content
  })
  
  shiny::removeModal()
  
  list(file = csv_file, content = content, path_list = path_list)
}
