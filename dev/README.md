---
title: "Onboarding"
output:
  rmarkdown::html_vignette:
    toc: true
    number_sections: true
---

<style>
body .main-container {
  max-width: 1280px !important;
  width: 1280px !important;
}
body {
  max-width: 1280px !important;
}

h1 {
  text-align: center;
}

table {
        width: 50%;
        text-align: center;
    }
</style>


# Welcome!

<center>

[logo](images/logo.png)

</center>

Hi there! Glad to have you on board. This is a guide to help you help us. If anything is unclear, questions can be asked by posting on [Github Discussions](https://github.com/D-Se/ML/discussions), or by sending an email to `r paste0(gsub("[<>]", "", strsplit(maintainer("ML"), "<")[[1]] |> trimws()), collapse = " at: ")`.

## Project Goals

-   *Deliver* a **scalable**, **reproducible** and **continuously integrated** data analysis compendium that:

    -   *Deploys* Machine Learning algorithms,

    -   *Visualizes* model performances & statistical inference,

    -   *Communicates* findings to target audiences in multiple formats.

-   *Display* best practices at the edge of machine learning knowledge using **R**, placing importance on:

    -   *Packaging* approaches using version control,

    -   *Deploying* computationally efficient algorithms,

    -   *Interfacing* modelling & reporting API's,

    -   *Adopting* a functional programming mindset.

## Project deliverables

-   A data analysis report in **pdf** format,

-   An R package containing `target`-based `tidymodels` approach,

-   A pipeline-generated `bookdown` book,

-   Github repository of mock firm & analysis.

## Meet the team

```{=html}
<style>
div.green { background-color:#93ed99; border-radius: 5px; padding: 20px;}
</style>
```
::: green
<center>

We are currently <B> recruiting! </B>

</center>
:::

+---------------+------------------------+------------------------------------------------------------------------------------+
| Name          | School                 | Responsibilities                                                                   |
+:=============:+:======================:+:==================================================================================:+
| Donald Seinen | Information Management | Project Management \| Quality Assurance \| Modelling \| Visualization \| Reporting |
+---------------+------------------------+------------------------------------------------------------------------------------+
| ...           | ...                    | ...                                                                                |
+---------------+------------------------+------------------------------------------------------------------------------------+
| ...           | ...                    | ...                                                                                |
+---------------+------------------------+------------------------------------------------------------------------------------+
| ...           | ...                    | ...                                                                                |
+---------------+------------------------+------------------------------------------------------------------------------------+
| ...           | ...                    | ...                                                                                |
+---------------+------------------------+------------------------------------------------------------------------------------+

## Getting started

1.  Sign the [non-disclose agreement](https://github.com/D-Se/ML/tree/master/inst) (Only in effect until **August 31, 2022**).

2.  Install project tools and dependencies by running `devtools::install_github("D-Se/ML")` in the R console.

3.  Connect RStudio to github ([guide](https://happygitwithr.com/rstudio-git-github.html)).

4.  Fork the Github repository.

5.  Find [issues](https://github.com/D-Se/ML/issues) to solve (picked by you or assigned to you).

# About the project

## Tools

This project uses **R & C++** for core development, **HTML, CSS & JavaScript** for reporting.

## R packages

This is a (partial) list of packages used in the project at various stages:

### Data wrangling

| Package      | Description        | Resource |
|--------------|--------------------|----------|
| `dplyr`      | Data wrangling     |          |
| `data.table` | Speedy data.frames |          |


### Reporting packages

+--------------+---------------------------+-----------------------------------------------+
| Package      | Description               | Resources                                     |
+==============+===========================+===============================================+
| `ggplot2`    | Data visualization        |                                               |
+--------------+---------------------------+-----------------------------------------------+
| `plotly`     | Interactive plots         |                                               |
+--------------+---------------------------+-----------------------------------------------+
| `visNetwork` | Ntwork graphs             |                                               |
+--------------+---------------------------+-----------------------------------------------+
| `rmarkdown`  | Markdown with an R accent | [Book](https://bookdown.org/yihui/rmarkdown/) |
+--------------+---------------------------+-----------------------------------------------+
| `bookdown`   |                           |                                               |
+--------------+---------------------------+-----------------------------------------------+
| `shiny`      | Web application framework |                                               |
+--------------+---------------------------+-----------------------------------------------+

### Modelling packages

+--------------+------------------------------------------+------------------------------------------------------------------------+
| Package      | Description                              | Resources                                                              |
+==============+==========================================+========================================================================+
| `keras`      | APi to `tensorflow` neural nets          | [keras](https://keras.io/) ; [TensorFlow](https://www.tensorflow.org/) |
+--------------+------------------------------------------+------------------------------------------------------------------------+
| `rpart`      | Regression trees                         |                                                                        |
+--------------+------------------------------------------+------------------------------------------------------------------------+
| `glmnet`     | Penalized maximum likelihood models      |                                                                        |
+--------------+------------------------------------------+------------------------------------------------------------------------+
| `earth`      | Multivariate Adaptive Regression Splines |                                                                        |
+--------------+------------------------------------------+------------------------------------------------------------------------+
| `rsample`    | Data sampling                            |                                                                        |
+--------------+------------------------------------------+------------------------------------------------------------------------+
| `recipes`    | Pre-processor specification              | [Book](https://www.tmwr.org/)                                          |
+--------------+------------------------------------------+------------------------------------------------------------------------+
| `parsnip`    | Model specification                      |                                                                        |
+--------------+------------------------------------------+------------------------------------------------------------------------+
| `tune`       | Hyper parameter tuning                   |                                                                        |
+--------------+------------------------------------------+------------------------------------------------------------------------+
| `workflows`  |                                          |                                                                        |
+--------------+------------------------------------------+------------------------------------------------------------------------+

### Package development

+---------------+--------------------------------+----------------------------------------------------------------------+
| Package       | Description                    | Resources                                                            |
+===============+================================+======================================================================+
| `targets`     | Make-like pipeline toolkit     | [Book](https://books.ropensci.org/targets/)                          |
+---------------+--------------------------------+----------------------------------------------------------------------+
| `tarchetypes` | Function-oriented `targets`    |                                                                      |
+---------------+--------------------------------+----------------------------------------------------------------------+
| `rlang`       | Tidyverse programming toolbox  |                                                                      |
+---------------+--------------------------------+----------------------------------------------------------------------+
| `testthat`    | Unit testing                   | [Book](https://r-pkgs.org/tests.html)                                |
+---------------+--------------------------------+----------------------------------------------------------------------+
| `lifecycle`   | function life cycle management |                                                                      |
+---------------+--------------------------------+----------------------------------------------------------------------+
| `future`      | Parallel processing framework  |                                                                      |
+---------------+--------------------------------+----------------------------------------------------------------------+
| `promises`    | Asynchronous programming       | [website](https://rstudio.github.io/promises/articles/overview.html) |
+---------------+--------------------------------+----------------------------------------------------------------------+
| `crayon`      | Pretty console printing        |                                                                      |
+---------------+--------------------------------+----------------------------------------------------------------------+

## Github repo

The [Github repo](https://github.com/D-Se/ML) is where the project lives. In it, you can find the following files. This may change in future releases.

```{verbatim}
├── .github  >>> github workflows, automated checking
├── R/  >>> directory for ML package functions.
├──── ... >>> regular R package functions. o sub-directory allowed.
├── inst/  >>> supplementary materials for ML package
├── man/  >>> automatically generated package documentation [NO EDIT]
├──── figures/ >>> images used
├── src/  >>> compiled (C++) code used in ML package
├── tests/  >>> unit tests for package functions
├──── testthat/ >>> directory of unit test
├── vignettes/  >>> long-form documentation
├── .Rbuildignore/ >>> package utility: instruction set to ignore non-standard files
├── .gitignore  >>> instruction set to RStudio to ignore files in directory for version control
├── DESCRIPTION  >>> R package metadata file
├── ML.Rproj  >>> RStudio file [NO EDIT]
├── NAMESPACE  >>> automatically generated R package build file [NO EDIT]
├── README.Rmd  >>> Github introduction file with executable R code
├── README.md >>> automatically generated Github introduction file [NO EDIT]
├── run.sh  >>> shell script to execture pipeline
├── run.R  >>>
├── _targets.R  # core pipeline
└── report.Rmd  
```

The project is split up into segments, each ending with finishing a deliverable. These steps can be found in the [milestones](https://github.com/D-Se/ML/milestones) section of the repo. The milestones are made up of collections of [issues](https://github.com/D-Se/ML/issues). These are tasks assigned to project members, and can be added by any person with access rights to the repo. [labels](https://github.com/D-Se/ML/labels) are placed on issues to make it easy to find and assign tasks. Each issue is allocated a *difficulty* and *priority* label, and further labels were appropriate.

# External Resources - learning & finding help

## R resources

-   [Link portal](https://www.bigbookofr.com/index.html)

-   [Book selection](https://bookdown.org/home/archive/)

## Visualization

-   [R Graph gallery](https://www.r-graph-gallery.com/)

## Modelling

-   [Feature Engineering & Selection](https://bookdown.org/max/FES/)
-   [Deep Learning](https://github.com/janishar/mit-deep-learning-book-pdf/tree/master/complete-book-pdf)

## Reporting

-   [rmarkdown cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/)
-   [markdown custom styling](https://holtzy.github.io/Pimp-my-rmd/)

# Productivity tips

A list of useful version controlled R project commands:

-   `devtools::document()` to update (locally) the package using `roxygen2.`

-   `lintr::lint_dir()` to use static code analysis for code formatting checks.

`lintr` is useful to check code style line-by-line and make adjustments on the fly. It will open an interface in the RStudio *Markers* pane where individual lines can be clicked. On a click, the relevant code snippet will be opened in the editor. This command is also run automatically on commits to the master branch of Github repo, viewable as comments in the Github Actions pane.

-   `covr::report()` for visual inspection of unit test coverage.

-   `usethis::edit_r_profile()` to run functions on startup.

An example of Donald's ML-project specific R profile line: runs `library(devtools)` and imports specific `targets` functions as an alias for brevity.

```
if (tryCatch(endsWith(readLines("DESCRIPTION", 1), "ML"), warning = function(x) F)) {
  #library(devtools, quietly = T)
  cat("loading devtools & select targets functions\n")
  box::use(
    devtools[...],
    targets[make = tar_make,
            make_future = tar_make_future,
            grab = tar_read]
  )
}
```

```{=html}

&nbsp;
<hr />
<p style="text-align: center;">Written by <a href="https://github.com/D-Se/">Donald Seinen</a></p>
<p style="text-align: center;"><span style="color: #808080;"><em>2869830202@qq.com</em></span></p>


<!-- Add icon library -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">


<!-- Add font awesome icons -->
<p style="text-align: center;">
    <a href="https://github.com/D-Se/" class="fa fa-github"></a>
</p>

&nbsp;
```
