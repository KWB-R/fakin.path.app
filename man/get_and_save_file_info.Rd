% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_and_save_file_info.R
\name{get_and_save_file_info}
\alias{get_and_save_file_info}
\title{Get and Save File Information}
\usage{
get_and_save_file_info(root_dir, output_dir, check_dirs = TRUE,
  format = "\%Y-\%m-\%d_\%H\%M", ...)
}
\arguments{
\item{root_dir}{path to the directory from which to start searching for
files}

\item{output_dir}{path to the output directory. In this directory, a file
"path-info_<date-time>_<parent-folder>.csv" will be generated with
<date-time> being a date and time string in yyyy-mm-dd_HHMM format and
<parent-folder> being the last path segment of \code{root_dir}}

\item{check_dirs}{if \code{TRUE} (default) it is checked in advance if both
\code{root_dir} and \code{output_dir} exist. Switch this off if e.g.
network paths are wrongly considered to be non-existing.}

\item{format}{format string specifying how to format the part of the
filename intended to contain date (and, if required, time) information.
Default: "\%Y-\%m-\%d_\%H\%M"}

\item{\dots}{further arguments passed to
\code{\link{get_recursive_file_info}} and finally to
\code{fs::dir_info}. Set e.g. \code{fail = FALSE} to avoid failure
due to insufficient access permissions.}
}
\value{
full path to the file to which all file information were written
}
\description{
Get and Save File Information
}
