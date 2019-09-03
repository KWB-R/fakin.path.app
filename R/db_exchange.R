# get_available_database_entries -----------------------------------------------
get_available_database_entries <- function()
{
  if (length(get_environment_vars("PATHANA_mysql")) == 0) {
    return(NULL)
  }
  
  datasets <- get_path_summary_from_database()
  
  if (nrow(datasets) == 0) {
    return(NULL)
  }
  
  paste0("db | ", kwb.utils::pasteColumns(
    x = datasets, 
    columns = c("scanned", "keyword"),
    sep = " | "
  ))
}

# extract_date -----------------------------------------------------------------
extract_date <- function(path_file)
{
  gsub("^.*(\\d{4})(\\d{2})(\\d{2}).*$", "\\1-\\2-\\3", basename(path_file))
}

# extract_keyword --------------------------------------------------------------
extract_keyword <- function(path_file)
{
  gsub("^.*\\d{8}_(.*)\\.csv$", "\\1", basename(path_file))
}

# get_path_summary_from_database -----------------------------------------------
get_path_summary_from_database <- function()
{
  select_from_fakin_database(paste(
    "SELECT scanned, keyword FROM pathana_summary", 
    "ORDER BY scanned DESC, keyword"
  ))
}

# get_path_data_from_database --------------------------------------------------
get_path_data_from_database <- function(scan_date = NULL, keyword = NULL)
{
  result <- select_from_fakin_database(statement = sprintf(
    "SELECT * FROM pathana WHERE keyword = '%s' AND scanned = '%s'", 
    keyword, scan_date
  ))
}
