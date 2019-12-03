# name_is_ok -------------------------------------------------------------------

#' Is the Name Ok According to Our Best Practices?
#'
#' @param x vector of character
#' @param mildness level of mildness. 1: not mild, all characters must be
#'   hyphen or alphanumeric or dot or underscore, 2: more mild, all characters
#'   must be one of the above or space
#' @export
#'
#' @return vector of logical as long as \code{x}
#'
#' @examples
#' name_is_ok(c("a", "$", ".", " "))
#' name_is_ok(c("a", "$", ".", " "), mildness = 2)
#'
name_is_ok <- function(x, mildness = 1)
{
  stopifnot(mildness %in% 1:2)
  
  patterns <- list(
    "^[-A-Za-z0-9._]+$",
    "^[-A-Za-z0-9._ ]+$"
  )
  
  grepl(patterns[[mildness]], x)
}
