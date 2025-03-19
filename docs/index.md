# asli-pipeline
<!-- badges: start -->
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14552486.svg)](https://doi.org/10.5281/zenodo.14552486)
![Dev Status](https://img.shields.io/badge/Status-Active-green)
[![Static Badge](https://img.shields.io/badge/GitHub_repo-black?logo=github)](https://github.com/antarctica/asli-pipeline)
[![Documentation](https://img.shields.io/badge/Documentation-blue)](https://antarctica.github.io/asli-pipeline/)
<!-- badges: end -->

This repository contains a pipeline for operational execution of the Amundsen Sea Ice Low calculations, provided in the `asli` package. The functions in the `asli` package are described in detail in the [package repository](https://github.com/davidwilby/amundsen-sea-low-index) `amundsen-sea-low-index` (Hosking & Wilby 2024), and in _Hosking et al. (2016)_.

This pipeline was built using the [icenet-pipeline](https://github.com/icenet-ai/icenet-pipeline) as a template (Byrne et al. 2024).  

## Clone the repository
Clone this repository into a directory on your computer or HPC.
```
git clone git@github.com:antarctica/asli-pipeline.git asli-pipeline
```

## Creating an environment
```bash
# If you are working on JASMIN you will need to load in jaspy and jasr
module load jaspy 
module load jasr

# Or, on the BAS HPC:
module load mamba/r-* # any version above 4.*
module load python/3.12.3/gcc-11.4.1-n3s7

python -m venv asli_env

source asli_env/bin/activate
```

## Installing dependencies
To install all dependencies, inlcuding the `asli` package, run:
```bash
pip install -r requirements.txt

# For R, we are using {renv} to manage dependencies
# install.R uses renv::restore, in combination with
# automatic distro detection to install R & system 
# dependencies
R -f install.R
```

### Packages and Virtual Environments on JASMIN
If you are working on JASMIN, it is good to familiarise yourself with managing software environments on Jasmin:
   1. [Quick Start on software for JASMIN](https://help.jasmin.ac.uk/docs/software-on-jasmin/quickstart-software-envs/)
   2. [Python Virtual Environments for JASMIN](https://help.jasmin.ac.uk/docs/software-on-jasmin/python-virtual-environments/).

## Climate Data Store API
The `asli` package will not be able to download ERA5 data without access to the [Copernicus Climate Data Store](https://cds.climate.copernicus.eu/cdsapp#!/home).

Follow these instructions to set up CDS API access: [How to Use The CDS API](https://cds-beta.climate.copernicus.eu/how-to-api).

```bash
nano $HOME/.cdsapirc
# Paste in your {uid} and {api-key} 
```