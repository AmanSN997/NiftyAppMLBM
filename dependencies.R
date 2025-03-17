# dependencies.R

# List of required packages
required_packages <- c("shiny", "quantmod", "tidyverse", "lubridate", "plotly")

# Function to check and install missing packages
install_missing_packages <- function(packages) {
  for (package in packages) {
    if (!requireNamespace(package, quietly = TRUE)) {
      install.packages(package)
    }
  }
}

# Install missing packages
install_missing_packages(required_packages)

# Load required packages
lapply(required_packages, library, character.only = TRUE)
