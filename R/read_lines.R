# read_lines -------------------------------------------------------------------

#' Read Lines by Giving the File Encoding
#'
#' @param file a connection object or character string
#' @param \dots arguments passed to \code{\link{readLines}}
#' @param encoding passed to \code{\link{readLines}}.
#' @param fileEncoding The name of the encoding to be assumed. Passed as
#'   \code{encoding} to \code{\link{file}}, see there.
#' @export
#'
read_lines <- function(file, ..., encoding = "unknown", fileEncoding = "")
{
  kwb.utils::warningDeprecated(
    "fakin.path.app:::read_lines", "kwb.utils::readLinesWithEncoding"
  )
  
  kwb.utils::readLinesWithEncoding(
    file, ..., fileEncoding = fileEncoding, encoding = encoding
  )
}

# default_local_encoding -------------------------------------------------------
default_local_encoding <- function(dbg = TRUE)
{
  encodings <- utils::localeToCharset()

  kwb.utils::catIf(dbg && length(encodings) > 1, sprintf(
    "Suggested encodings: %s\n", kwb.utils::stringList(encodings)
  ))

  encoding <- kwb.utils::defaultIfNA(encodings[1], "unknown")

  kwb.utils::catIf(dbg, sprintf("Selected encoding: '%s'\n", encoding))

  encoding
}
