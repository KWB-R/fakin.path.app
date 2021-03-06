[![Appveyor build Status](https://ci.appveyor.com/api/projects/status/ufb4myi4n730logd/branch/master?svg=true)](https://ci.appveyor.com/project/KWB-R/fakin-path-app/branch/master)
[![Travis build Status](https://travis-ci.org/KWB-R/fakin.path.app.svg?branch=master)](https://travis-ci.org/KWB-R/fakin.path.app)
[![codecov](https://codecov.io/github/KWB-R/fakin.path.app/branch/master/graphs/badge.svg)](https://codecov.io/github/KWB-R/fakin.path.app)
[![Project Status](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/fakin.path.app)]()

This package contains an R Shiny App that loads file path information from a
file and displays the paths in different ways.  The aim of the app is to find
weaknesses in given folder structures.

## Installation

You need to have R installed on your computer. R is a language and environment 
for statistical computing and graphics. The software is Open Source. 
For Windows, you find an installer file here: https://cran.r-project.org/bin/windows/base/

Once you have R installed, you need some additional so called R packages that
extend the functionality of the R environment. Start by installing the package
"remotes" that allows to directly install R packages from GitHub:

```r
install.packages("remotes", repos = "https://cloud.r-project.org")
```

Use the function `remotes::install_github()` from this package to install this package "fakin.path.app" and all other packages that this package depends on:

```r
remotes::install_github("KWB-R/fakin.path.app")
```

If all packages are installed, you can run the application by:

```r
fakin.path.app::run_app()
```

This opens the main window with some example data being preloaded. You can play 
around with these data.

For analysing your own folder structures, you need to provide path information.
You may use another small web application that is contained in this package to 
provide path information about your own files. You run the application by
running the following code in the R console:

```r
# Run web application to generate path information about your own files
fakin.path.app::run_app_scan()
```

By default, the app writes path information files to a folder `"~/pathana-db"`.
You can change this folder within the app. 

Once path information files are available, call the main app by giving the path 
to this folder:

```r
# Set the path to the "path database"
path_database <- "~/pathana-db"

# Run the main app giving the path to the "path database"
fakin.path.app::run_app(path_database)
```
