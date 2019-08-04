# find_duplicates --------------------------------------------------------------

#' @importFrom kwb.utils selectColumns
#' @importFrom pathlist filename folder
#' @keywords internal
find_duplicates <- function(path_list, min_size = 10, time_column = "modified")
{
  stopifnot(inherits(path_list, "pathlist"))

  pl <- path_list[which(path_list@data$size >= min_size)]

  columns <- c("size", time_column)

  x <- cbind(
    kwb.utils::selectColumns(pl@data, columns),
    filename = pathlist::filename(pl),
    folder = pathlist::folder(pl)
  )

  cols <- 1:3

  is_duplicate <- duplicated(x[, cols])

  x_left <- unique(x[is_duplicate, cols])

  result <- merge(x_left, x, by = names(x)[cols], all.x = TRUE)

  result[order(result$size, decreasing = TRUE), c("size", "folder", "filename")]
}
