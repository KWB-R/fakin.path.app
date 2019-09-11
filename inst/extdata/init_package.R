# Set the name of your (!) new package
package <- "fakin.path.app"

# Set the path to your (!) local folder to which GitHub repositories are cloned
repo_dir <- "~/github-repos"

# Set the path to the package directory
pkg_dir <- file.path(repo_dir, package)

# Create directory for R package
kwb.pkgbuild::create_pkg_dir(pkg_dir)

# Create a default package structure
withr::with_dir(pkg_dir, kwb.pkgbuild::use_pkg_skeleton(package))

author <- list(
  name = "Hauke Sonnenberg", 
  orcid = "0000-0001-9134-2871",
  url = "https://github.com/hsonne"
)

description <- list(
  name = package, 
  title = "Shiny App to Visialise File Paths", 
  desc  = paste(
    "This package contains an R Shiny App that loads file path information", 
    "from a file and displays the paths in different ways.  The aim of the", 
    "app is to find weaknesses in the folder structure."
  )
)

setwd(pkg_dir)

kwb.pkgbuild::use_pkg(
  author, 
  description, 
  version = "0.0.0.9000", 
  stage = "experimental"
)

pkg_dependencies <- c(
  "DT", "kwb.file", "kwb.utils", "networkD3", "shiny"
)

sapply(pkg_dependencies, usethis::use_package)
