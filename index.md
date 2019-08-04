[![Appveyor build
Status](https://ci.appveyor.com/api/projects/status/github/KWB-R/fakin.path.app?branch=master&svg=true)](https://ci.appveyor.com/project/KWB-R/fakin-path-app/branch/master)
[![Travis build
Status](https://travis-ci.org/KWB-R/fakin.path.app.svg?branch=master)](https://travis-ci.org/KWB-R/fakin.path.app)
[![codecov](https://codecov.io/github/KWB-R/fakin.path.app/branch/master/graphs/badge.svg)](https://codecov.io/github/KWB-R/fakin.path.app)
[![Project
Status](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/fakin.path.app)]()

This package contains an R Shiny App that loads file path information
from a file and displays the paths in different ways. The aim of the app
is to find weaknesses in given folder structures.

Installation
------------

You need to have R installed on your computer. R is a language and
environment for statistical computing and graphics. The software is Open
Source. For Windows, you find an installer file here:
<https://cran.r-project.org/bin/windows/base/>

Once you have R installed, you need some additional so called R packages
that extend the functionality of the R environment. Start by installing
the package "remotes" that allows to directly install R packages from
GitHub:

    install.packages("remotes", repos = "https://cloud.r-project.org")

Use the function `install_github()` from this package to install this
package "fakin.path.app" and all other packages that this package
depends on:

    remotes::install_github("KWB-R/fakin.path.app")

If all packages are installed, you can run the application by:

    fakin.path.app::run_app()

This opens the main window with some example data being preloaded. You
can play around with these data.

For analysing your own folder structures, you need to provide path
information. You may use a function from the package "kwb.fakin" to
provide such a file:

    # Set the path to the root folder
    root_dir <- "~/Documents"

    # Let R find all file paths below the root folder
    file_info <- kwb.fakin::get_recursive_file_info(root_dir)

    ## Getting file information on files below ~/Documents ... ok. (1.72s)

    # Get an impression of the information returned
    str(file_info)

    ## Classes 'tbl', 'tbl_df' and 'data.frame':    11566 obs. of  18 variables:
    ##  $ path             :Classes 'fs_path', 'character'  chr [1:11566] "/home/hauke/Documents/142___08" "/home/hauke/Documents/142___08/IMG_7330.JPG" "/home/hauke/Documents/142___08/IMG_7331.JPG" "/home/hauke/Documents/142___08/IMG_7332.JPG" ...
    ##  $ type             : Factor w/ 8 levels "any","block_device",..: 4 7 7 7 7 7 7 7 7 7 ...
    ##  $ size             :Class 'fs_bytes'  num [1:11566] 12288 631586 425549 655252 815279 ...
    ##  $ permissions      :Class 'fs_perms'  int [1:11566] 16877 33188 33188 33188 33188 33188 33188 33188 33188 33188 ...
    ##  $ modification_time: POSIXct, format: "2018-12-16 13:39:11" "2018-08-06 09:35:24" ...
    ##  $ user             : chr  "hauke" "hauke" "hauke" "hauke" ...
    ##  $ group            : chr  "hauke" "hauke" "hauke" "hauke" ...
    ##  $ device_id        : num  2049 2049 2049 2049 2049 ...
    ##  $ hard_links       : num  2 1 1 1 1 1 1 1 1 1 ...
    ##  $ special_device_id: num  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ inode            : num  2887742 2887752 2887753 2887754 2887755 ...
    ##  $ block_size       : num  4096 4096 4096 4096 4096 ...
    ##  $ blocks           : num  24 1240 832 1280 1600 ...
    ##  $ flags            : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ generation       : num  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ access_time      : POSIXct, format: "2019-08-03 22:06:28" "2018-12-16 13:39:22" ...
    ##  $ change_time      : POSIXct, format: "2018-12-16 13:39:11" "2018-12-16 13:38:50" ...
    ##  $ birth_time       : POSIXct, format: "2018-12-16 13:39:11" "2018-12-16 13:38:50" ...

    # Set the path to the directory in which to save path information files
    target_dir <- "~/Documents/path_info_files"

    # Create the target directory
    dir.create(target_dir)

    ## Warning in dir.create(target_dir): '/home/hauke/Documents/path_info_files'
    ## already exists

    # Create the path to the target file
    filename <- format(Sys.Date(), format = "my-files_%Y%m%d.csv")

    # Write the path information to a file
    kwb.fakin::write_file_info(file_info, file = file.path(target_dir, filename))

    ## Writing to '~/Documents/path_info_files/my-files_20190804.csv' with data.table::fwrite() ... ok. (0.31s) 
    ## Elapsed: 0.307

Call the app by giving the path to the target folder:

    fakin.path.app::run_app(path_database = target_dir)
