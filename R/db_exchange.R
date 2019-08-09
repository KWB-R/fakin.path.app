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
  
  paste0("db|", kwb.utils::pasteColumns(
    x = datasets, 
    columns = c("scanned", "keyword"),
    sep = "|"
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

# connect_to_fakin_db ----------------------------------------------------------
connect_to_fakin_db <- function()
{
  RMySQL::dbConnect(
    RMySQL::MySQL(), 
    host = get_global("mysql_host"), # Sys.getenv("PATHANA_mysql_host"), 
    dbname = get_global("mysql_dbname"), # Sys.getenv("PATHANA_mysql_dbname"), 
    user = get_global("mysql_user"), # Sys.getenv("PATHANA_mysql_user"), 
    password = get_global("mysql_password") # Sys.getenv("PATHANA_mysql_password")
  )
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
  
  statement <- sprintf("SELECT * FROM paths WHERE %s;", condition)
  
  select_from_fakin_database(statement = statement)
}

# select_from_fakin_database ---------------------------------------------------
select_from_fakin_database <- function(statement)
{
  con <- connect_to_fakin_db()
  res <- RMySQL::dbSendQuery(con, statement)
  
  on.exit({
    RMySQL::dbClearResult(res)
    RMySQL::dbDisconnect(con)
  })
  
  RMySQL::dbFetch(res, n = -1)
}

# create_path_table_in_database ------------------------------------------------
create_path_table_in_database <- function()
{
  statement <- "CREATE TABLE paths (
    id INT NOT NULL AUTO_INCREMENT,
    keyword VARCHAR(32),
    path VARCHAR(512) NOT NULL,
    size DOUBLE NOT NULL,
    type VARCHAR(32) NOT NULL,
    created DATETIME,
    modified DATETIME,
    scanned DATE,
    PRIMARY KEY (id ASC),
    UNIQUE (path, scanned)
  ) DEFAULT CHARSET=utf8 ENGINE=InnoDB;"
  
  con <- connect_to_fakin_db()
  res <- RMySQL::dbSendQuery(con, statement)
  
  on.exit({
    RMySQL::dbClearResult(res)
    RMySQL::dbDisconnect(con)
  })
}
