# common_rootUI ----------------------------------------------------------------
common_rootUI <- function(id)
{
  shiny::tagList(
    checkbox_remove_common_root,
    checkbox_keep_first_root
  )
}

# common_root ------------------------------------------------------------------
common_root <- function(input, output, session)
{
  
}