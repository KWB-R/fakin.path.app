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
  select_from_fakin_database(
    statement = "SELECT 
      keyword, scanned, sum(size) as size_mib, count(*) as n_files 
      FROM paths GROUP BY keyword, scanned;"
  )
}

# get_path_data_from_database --------------------------------------------------
get_path_data_from_database <- function(scan_date = NULL, keyword = NULL)
{
  args <- stats::setNames(list(scan_date, keyword), c("scanned", "keyword"))
  args <- kwb.utils::excludeNULL(args, dbg = FALSE)

  condition <- if (length(args)) {
    paste(collapse = " AND ", sprintf("%s = '%s'", names(args), unlist(args)))
  } else {
    TRUE
  }
  
  select_from_fakin_database(statement = sprintf(
    "SELECT * FROM paths WHERE %s;", condition
  ))
}

# create_path_table_in_database ------------------------------------------------
create_path_table_in_database <- function()
{
  run_in_fakin_database(
    statement = paste(c(
      "CREATE TABLE paths (",
      "  id INT NOT NULL AUTO_INCREMENT,",
      "  keyword VARCHAR(32),",
      "  path VARCHAR(512) NOT NULL,",
      "  size DOUBLE NOT NULL,",
      "  type VARCHAR(32) NOT NULL,",
      "  created DATETIME,",
      "  modified DATETIME,",
      "  scanned DATE,",
      "  PRIMARY KEY (id ASC),",
      "  UNIQUE (path, scanned)",
      ") DEFAULT CHARSET = utf8 ENGINE = InnoDB;"
    ))
  )
}
