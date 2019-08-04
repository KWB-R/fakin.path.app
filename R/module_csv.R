# csvFileUI --------------------------------------------------------------------

#' @importFrom shiny NS tagList selectInput
#' @keywords internal
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

#' @importFrom kwb.fakin extdata_file
#' @importFrom kwb.utils removeExtension multiSubstitute
#' @importFrom stats setNames
#' @keywords internal
get_file_info_files <- function(path_database)
{
  files <- c(
    dir_or_stop(kwb.fakin::extdata_file(""), "^example_file_info.*\\.csv$"),
    dir_or_stop(path_database, "\\.csv$")
  )

  # Give user friendly labels to the files to appear in the dropdown list 
  file_labels <- kwb.utils::removeExtension(basename(files))
  
  replacements <- list(
    "^path-info(-ps-1)?_" = "",
    "(\\d{2})_\\d{4}" = "\\2"
  )

  stats::setNames(files, kwb.utils::multiSubstitute(file_labels, replacements))
}

# csvFile ----------------------------------------------------------------------

#' @importFrom shiny reactive
#' @importFrom kwb.fakin read_file_paths
#' @importFrom kwb.utils selectColumns
#' @importFrom pathlist pathlist hide_server
#' @keywords internal
csvFile <- function(input, output, session, read_function)
{
  # Path to CSV file
  csv_file <- shiny::reactive({
    input$file
  })
  
  # Path to RDS file in the same folder
  rds_file <- shiny::reactive({
    gsub("\\.csv$", ".rds", csv_file())
  })
  
  # Does the RDS file already exist?  
  rds_file_exists <- shiny::reactive({
    file.exists(rds_file())
  })
  
  raw_content <- shiny::reactive({
    
    if (rds_file_exists()) {
      return(NULL)
    }
      
    x <- run_with_modal(
      text = paste("Reading", basename(csv_file())),
      expr = kwb.fakin::read_file_paths(csv_file())
    )
    
    kwb.utils::selectColumns(
      x = normalise_column_names(x), 
      columns = c("path", "type", "size", "modified")
    )
  })
  
  rds_content <- shiny::reactive({
    
    if (! rds_file_exists()) {
      return(NULL)
    }
      
    run_with_modal(
      text = paste("Loading", basename(rds_file())),
      expr =readRDS(rds_file())
    )
  })
  
  path_list <- shiny::reactive({
    
    if (! is.null(rds_content())) {
      return(rds_content()$path_list)
    }
    
    run_with_modal(
      text = "Providing table data",
      expr = pathlist::hide_server(pathlist::pathlist(
        paths = raw_content()$path, 
        data = raw_content()[, c("type", "size")]
      ))
    )
  })
  
  content <- shiny::reactive({
    
    if (! is.null(rds_content())) {
      return(rds_content()$content)
    }
    
    x <- prepare_full_path_table(x = raw_content(), pl = path_list())
    
    content <- structure(x, root = path_list()@root)
    
    rds_content <- list(content = content, path_list = path_list())
    
    run_with_modal(
      text = paste("Caching data in", basename(rds_file())),
      expr = saveRDS(rds_content, file = rds_file())
    )
    
    content
  })
  
  list(file = csv_file, content = content, path_list = path_list)
}

# prepare_full_path_table ------------------------------------------------------

#' @importFrom kwb.utils fileExtension moveColumnsToFront removeColumns 
#' @importFrom kwb.utils selectColumns
#' @importFrom pathlist depth filename folder toplevel
#' @keywords internal
prepare_full_path_table <- function(x, pl)
{
  # Convert column "modified" to POSIXct
  timestamps <- kwb.utils::selectColumns(x, "modified")
  x$modified <- as.Date(as.POSIXct(timestamps, "%Y-%m-%dT%H:%M:%S", tz = "UTC"))

  # Provide/format columns "size", "toplevel", "folder", "filename"  
  x$size <- round(x$size, 6)
  x$toplevel <- factor(pathlist::toplevel(pl))
  x$folder <- pathlist::folder(pl)
  x$filename <- pathlist::filename(pl)

  # Provide column "extension"  
  x$extension <- ""
  is_file <- x$type == "file"
  x$extension[is_file] <- kwb.utils::fileExtension(x$filename[is_file])
  x$extension <- factor(x$extension)

  # Provide column "depth"  
  x$depth <- pathlist::depth(pl)

  # Remove column "path" and move main columns to the left
  x <- kwb.utils::removeColumns(x, "path")
  main_columns <- c("toplevel", "folder", "filename", "extension")
  kwb.utils::moveColumnsToFront(x, main_columns)
}
