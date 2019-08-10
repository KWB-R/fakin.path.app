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
send_query_to_fakin_db <- function(statement, fetch = FALSE, dbg = TRUE, n = -1)
{
  con <- connect_to_fakin_database()
  on.exit(RMySQL::dbDisconnect(con))
  
  kwb.utils::catAndRun(
    sprintf("Running query in fakin database:\n%s\n", statement),
    dbg = dbg, 
    send_query_fetch_optionally(con, statement, fetch = fetch, n = n)
  )
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

# send_query_fetch_optionally --------------------------------------------------
send_query_fetch_optionally <- function(con, statement, fetch = FALSE, n = -1)
{
  res <- RMySQL::dbSendQuery(con, statement)
  on.exit(RMySQL::dbClearResult(res))
  
  if (fetch) {
    RMySQL::dbFetch(res, n = n)
  }
}
