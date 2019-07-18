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
    "path-info_" = "",
    "(\\d{2})_\\d{4}" = "\\1"
  ))
  
  stats::setNames(files, names)
}

# csvFile ----------------------------------------------------------------------
csvFile <- function(input, output, session, read_function)
{
  file_path <- shiny::reactive(input$file)

  raw_content <- shiny::reactive({
    file <- file_path()
    x <- kwb.fakin::read_file_paths(file)
    x <- kwb.utils::renameColumns(x, list(
      modification_time = "modified", 
      last_access = "modified",
      LastWriteTimeUtc = "modified"
    ))
    kwb.utils::selectColumns(x, c("path", "type", "size", "modified"))
  })

  path_list <- shiny::reactive({
    pathlist::pathlist(paths = raw_content()$path)
  })
  
  content <- shiny::reactive({
    x <- raw_content()
    dates <- as.Date(as.POSIXct(x$modified, "%Y-%m-%dT%H:%M:%S", tz = "UTC"))
    x$modified <- dates
    x$size <- round(x$size, 3)
    x$toplevel <- factor(pathlist::toplevel(path_list()))
    x$folder <- pathlist::folder(path_list())
    x$filename <- pathlist::filename(path_list())
    x$extension <- ""
    is_file <- x$type == "file"
    x$extension[is_file] <- kwb.utils::fileExtension(x$filename[is_file])
    x$extension <- factor(x$extension)
    x$depth <- path_list()@depths

    x <- kwb.utils::moveColumnsToFront(kwb.utils::removeColumns(x, "path"), c(
      "toplevel", "folder", "filename", "extension"
    ))
    
    structure(x, root = path_list()@root)
  })
  
  list(file = file_path, content = content, path_list = path_list)
}
