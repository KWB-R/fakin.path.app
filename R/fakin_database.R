# select_from_fakin_database ---------------------------------------------------
select_from_fakin_database <- function(statement, dbg = TRUE)
{
  send_query_to_fakin_db(statement, fetch = TRUE, dbg = dbg, n = -1)
}

# run_in_fakin_database --------------------------------------------------------
run_in_fakin_database <- function(statement, dbg = TRUE)
{
  send_query_to_fakin_db(statement, fetch = FALSE, dbg = dbg)
}

# send_query_to_fakin_db -------------------------------------------------------
send_query_to_fakin_db <- function(statement, fetch = TRUE, dbg = TRUE, n = -1)
{
  con <- connect_to_fakin_database()
  
  res <- kwb.utils::catAndRun(
    sprintf("Running query in fakin database:\n%s\n", statement),
    dbg = dbg,
    RMySQL::dbSendQuery(con, statement)
  )
  
  on.exit({
    RMySQL::dbClearResult(res)
    RMySQL::dbDisconnect(con)
  })
  
  if (fetch) {
    RMySQL::dbFetch(res, n = n)
  }
}

# connect_to_fakin_database ----------------------------------------------------
connect_to_fakin_database <- function()
{
  RMySQL::dbConnect(
    RMySQL::MySQL(), 
    host = get_global("mysql_host"),
    dbname = get_global("mysql_dbname"),
    user = get_global("mysql_user"),
    password = get_global("mysql_password")
  )
}
