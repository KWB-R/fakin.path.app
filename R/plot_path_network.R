# plot_path_network ------------------------------------------------------------

#' Plot Paths as Sankey Network
#'
#' @param paths character vector of paths
#' @param max_depth maximum depth of paths to be shown
#' @param nodePadding passed to \code{\link[networkD3]{sankeyNetwork}}, see
#'   there. Decrease this value (e.g. `nodePadding = 0`) if there are
#'   many nodes to plot and the plot does not look as expected
#' @param nodeHeight height of a node in pixels. Used to calculate the total
#'   plot height.
#' @param sinksRight passed to \code{\link[networkD3]{sankeyNetwork}}, see there
#' @param remove_common_root remove the common root parts? (default: TRUE)
#' @param names_to_colours if not \code{NULL} expected to be a function that
#'   accepts a vector of (node) names and returns a vector of (colour) names
#'   of same length. This function will be called by \code{plot_path_network}
#'   to determine the colour for each node based on its name. By default, the
#'   function \code{\link{name_to_traffic_light}} is called.
#' @param height plot height in pixels, passed to
#'   \code{\link[networkD3]{sankeyNetwork}}. If \code{NULL}, the height is
#'   calculated based on \code{nodeHeight}, \code{nodePadding} and the maximum
#'   number of nodes at one folder depth.
#' @param \dots further arguments passed to
#'   \code{\link[networkD3]{sankeyNetwork}}, such as \code{nodeWidth},
#'   \code{nodePadding}, \code{fontSize}
#' @param method if \code{1} (default) the function behaves as before, another
#'   value activates the new preparation of paths accepting/using an object
#'   of class \pkg{pathlist}
#' @param weight_by one of \code{"n_files", "size", "none"}. Specifies whether
#'   to set the link widths according to the total number or total size of files
#'   in subsequent folders or by setting all links to the same width.
#' @param sizes file sizes corresponding to the \code{paths}
#' @return object representing an HTML page
#'
#' @export
#'
#' @examples
#' # Get the paths to all folders on the desktop
#' paths <- dir(system.file(package = "fakin.path.app"), recursive = TRUE)
#'
#' # Plot the folder network
#' plot_path_network(paths)
#'
plot_path_network <- function(
  paths, max_depth = 3, nodePadding = 8, nodeHeight = 10, sinksRight = FALSE,
  remove_common_root = TRUE, names_to_colours = name_to_traffic_light,
  height = NULL, ..., method = 1, weight_by = c("n_files", "size", "none")[1],
  sizes = NULL
)
{
  if (method == 1) {

    paths <- prepare_paths_for_network(paths, remove_common_root)
    network <- get_path_network(paths, max_depth)

  } else {

    paths <- prepare_paths_for_network2(paths)
    network <- get_path_network2(
      paths, max_depth, weight_by = weight_by, sizes = sizes
    )
  }

  if (! is.null(names_to_colours)) {
    network$nodes <- add_colours_to_nodes(network$nodes, names_to_colours)
  }

  if (is.null(height)) {
    height <- get_default_sankey_height(paths, nodeHeight, nodePadding)
  }

  arguments <- list(
    network$links, network$nodes, Source = "source", Target = "target",
    Value = "value", NodeID = "name", sinksRight = sinksRight,
    nodePadding = nodePadding, height = height, ...
  )

  colourScale <- attr(network$nodes, "colourScale")

  do.call(networkD3::sankeyNetwork, if (is.null(colourScale)) {
    c(arguments, NodeGroup = "name")
  } else {
    c(arguments, NodeGroup = "colour", colourScale = colourScale)
  })
}

# get_default_sankey_height ----------------------------------------------------
get_default_sankey_height <- function(paths, nodeHeight, nodePadding)
{
  actual_max_depth <- if (inherits(paths, "pathlist")) {
    max(pathlist::depth(paths))
  } else {
    get_max_path_width(paths)
  }

  (nodeHeight + nodePadding) * actual_max_depth
}

# prepare_paths_for_network ----------------------------------------------------
prepare_paths_for_network <- function(paths, remove_common_root, dbg = FALSE)
{
  # Remove the common root in order to "save" depth levels
  if (remove_common_root) {
    paths <- kwb.file::remove_common_root(paths, dbg = FALSE)
  }

  # If a path tree is given, flatten the tree into a vector of character
  if (is.list(paths)) {
    stop_(
      "Object of class 'path_tree' not expected in prepare_paths_for_network()!"
    )
    #paths <- flatten_tree(paths)
  }

  paths
}

# add_colours_to_nodes ---------------------------------------------------------
add_colours_to_nodes <- function(nodes, names_to_colours)
{
  stopifnot(is.function(names_to_colours))

  node_names <- as.character(kwb.utils::selectColumns(nodes, "name"))

  colours <- names_to_colours(node_names)

  stopifnot(length(colours) == length(node_names))

  # Comma separated, enquoted, unique colour strings
  string_list <- kwb.utils::stringList(unique(colours))

  # Format string required to define the colour scale with sprintf()
  fmt <- 'd3.scaleOrdinal() .domain([%s]) .range([%s])'

  # Add a column "colour" to the nodes table
  nodes$colour <- colours

  # Return the nodes table with an attribute "colourScale" added
  structure(nodes, colourScale = sprintf(fmt, string_list, string_list))
}

# name_to_traffic_light --------------------------------------------------------

#' Get Traffic Light Colours for Names
#'
#' @param x character of (file or folder) names, e.g. as they appear as
#'   node labels in the plot generated with \code{\link{plot_path_network}}
#'
#' @return vector of colour strings each of which is \code{green} (name does
#'   comply with naming convention), \code{yellow} (name does almost comply with
#'   naming convention), \code{red} (name does not comply with naming
#'   convention).
#'
#' @export
#'
#' @examples
#' # Define a vector of names
#' x <- c("has_speci&l", "has space", "is_ok")
#'
#' # Colour names by their compliance with naming convention
#' name_to_traffic_light(x)
#'
name_to_traffic_light <- function(x)
{
  colours <- rep("red", length(x))

  colours[name_is_ok(x, mildness = 2)] <- "yellow"

  colours[name_is_ok(x, mildness = 1)] <- "green"

  colours
}

# get_path_network -------------------------------------------------------------
get_path_network <- function(paths, max_depth = 3, reverse = FALSE)
{
  # Create data frame with each column representing a folder depth level
  folder_data <- kwb.utils::asNoFactorDataFrame(
    kwb.file::to_subdir_matrix(paths, dbg = FALSE)
  )

  # Reduce max_depth to the number of available columns
  max_depth <- min(max_depth, ncol(folder_data))

  # We need at least a depth of two
  stopifnot(max_depth >= 2)

  links <- do.call(rbind, lapply(2:max_depth, get_links_at_depth, folder_data))

  node_names <- unique(unlist(links[, -3]))

  get_matching_index <- function(x) match(x, node_names) - 1

  links$source <- get_matching_index(links$source)
  links$target <- get_matching_index(links$target)

  # Swap the names of columns "source" and "target" for reverse = TRUE
  if (isTRUE(reverse)) {

    elements <- c("source", "target")

    indices <- match(elements, names(links))

    names(links)[indices] <- rev(elements)
  }

  nodes <- kwb.utils::noFactorDataFrame(
    path = node_names, name = basename(node_names)
  )

  list(links = links, nodes = nodes)
}

# get_links_at_depth -----------------------------------------------------------
get_links_at_depth <- function(i, folder_data)
{
  # Select the first i columns
  source_data <- folder_data[, seq_len(i)]

  # Exclude rows being empty in the i-th column
  source_data <- source_data[source_data[, i] != "", ]

  # Count the number of files per path
  n_files <- stats::aggregate(source_data[, 1], by = source_data, length)

  # Define helper function
  n_columns_to_path <- function(data, n) {

    kwb.utils::pasteColumns(data[, seq_len(n), drop = FALSE], sep = "/")
  }

  # Create the data frame linking source to target nodes with value as weight
  kwb.utils::noFactorDataFrame(
    source = n_columns_to_path(n_files, i - 1),
    target = n_columns_to_path(n_files, i),
    value = n_files$x
  )
}

# get_max_path_width -----------------------------------------------------------
get_max_path_width <- function(paths)
{
  max(colSums(kwb.file::to_subdir_matrix(paths) != ""))
}
