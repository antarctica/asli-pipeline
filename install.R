# Selecting p3m.dev is an optional step for linux distros
# It will speed up installation and prevents the risk of installation 
# failing on external C libraries

# This is because CRAN only provides source packages for linux
# and not binary
# see: https://r-in-production.org/packages.html#installing-a-package-on-linux

# For Ubuntu 24.04
options(repos = c(CRAN = "https://p3m.dev/cran/__linux__/noble/latest"))

# For Rocky 9
# options(repos = c(CRAN = "https://p3m.dev/cran/__linux__/rhel9/latest"))

install.packages("pak")
pak::pak("thomaszwagerman/butterfly")
pak::pak("readr")
pak::pak("paws")
pak::pak("ini")