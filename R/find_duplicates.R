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

  j <- 1:3

  x_left <- unique(x[duplicated(x[, j]), j])

  result <- merge(x_left, x, by = names(x)[j], all.x = TRUE)

  columns <- c("size", "folder", "filename", time_column)
  
  duplicates <- result[order(result$size, decreasing = TRUE), columns]
  
  duplicates
}

# duplicates_to_saving_potential -----------------------------------------------

#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @importFrom dplyr arrange group_by mutate n select summarise ungroup 
#' @keywords internal
duplicates_to_saving_potential <- function(duplicates, time_column = "modified")
{
  duplicates %>%
    dplyr::group_by(.data$size, .data[[time_column]], .data$filename) %>%
    dplyr::summarise(count = dplyr::n(), total_size = sum(.data$size)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(potential = round(.data$total_size - .data$size, 3)) %>%
    dplyr::select(.data$filename, .data$size, .data$count, .data$potential) %>%
    dplyr::arrange(- .data$potential) %>%
    as.data.frame()
}
