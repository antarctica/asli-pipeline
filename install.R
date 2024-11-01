#!/usr/bin/env Rscript
# Usage R -f install.R

# This is not an R project, so need to manually "activate" renv
source("renv/activate.R")

# Moving on to installing r and system dependencies with renv.lock
# Have R obtain the current platform distro and release
# pak & pkgcache **should** be installed with renv
os <- data.frame(
  distribution = pkgcache::current_r_platform_data()$distribution,
  release = pkgcache::current_r_platform_data()$release
)

# Match with pak's ppm_platforms
os_table <- merge(
  os,
  pkgcache::ppm_platforms()
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