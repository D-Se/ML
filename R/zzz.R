.onAttach <- function(...) {
  check_updates()
}

check_updates <- function() {
 if(!version$major >= "4") {
   cli::cli_alert_info("Using an old R version, consider updating!")
 } else {
   cli::cli_alert_success("R version up-to-date for ML.")
 }
}


