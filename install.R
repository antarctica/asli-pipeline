#!/usr/bin/env Rscript
# Usage R -f install.R
# Tested on ubuntu, centos and rocky
#
# This will not work with opensuse and sle,
# naming inconsistencies across distros is hard

# This is not an R project, so need to manually "activate" renv
source("renv/activate.R")

install.packages("pkgcache")

# Moving on to installing r and system dependencies with renv.lock
# Have R obtain the current platform distro and release
# pak & pkgcache **should** be installed with renv
os <- data.frame(
  distribution = pkgcache::current_r_platform_data()$distribution,
  release = pkgcache::current_r_platform_data()$release
)

os$release <- round(as.numeric((os$release)))

# Some wrangling to make matching more reliable across distros
ppm_platforms <- pkgcache::ppm_platforms()

# Take the word "linux" out of distribution names
ppm_platforms$distribution <- gsub("linux", "", ppm_platforms$distribution)
ppm_platforms$release <- round(as.numeric((ppm_platforms$release)))

# Match with pak's ppm_platforms
os_table <- merge(
  os,
  ppm_platforms
)

if (os_table$os == "linux") {
  p3m_url <- paste0(
    "https://p3m.dev/cran/__linux__/",
  os_table$binary_url,
"/latest"
)
} else{
  p3m_url <- "https://p3m.dev/cran/latest"
}

renv::lockfile_modify(repos = c(
  P3M = p3m_url
)) |> 
renv::lockfile_write()

renv::restore()