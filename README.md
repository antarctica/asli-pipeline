# asli-pipeline

<!-- badges: start -->
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14552486.svg)](https://doi.org/10.5281/zenodo.14552486)
![Dev Status](https://img.shields.io/badge/Status-Active-green)
[![Static Badge](https://img.shields.io/badge/GitHub_repo-black?logo=github)](https://github.com/antarctica/asli-pipeline)
[![Documentation](https://img.shields.io/badge/Documentation-blue)](https://antarctica.github.io/asli-pipeline/)
<!-- badges: end -->

This repository contains a pipeline for operational execution of the Amundsen Sea Ice Low calculations, provided in the `asli` package. The functions in the `asli` package are described in detail in the [package repository](https://github.com/davidwilby/amundsen-sea-low-index) `amundsen-sea-low-index` (Hosking & Wilby 2024), and in _Hosking et al. (2016)_.

This pipeline was built using the [icenet-pipeline](https://github.com/icenet-ai/icenet-pipeline) as a template (Byrne et al. 2024).  

## Get the repository
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

### Installing dependencies
To install all dependencies, inlcuding the `asli` package, run:
```bash
pip install -r requirements.txt

# For R, we are using {renv} to manage dependencies
# install.R uses renv::restore, in combination with
# automatic distro detection to install R & system 
# dependencies
R -f install.R
```
## Setting up Climate Data Store API
The `asli` package will not be able to download ERA5 data without access to the [Copernicus Climate Data Store](https://cds.climate.copernicus.eu/cdsapp#!/home).

Follow these instructions to set up CDS API access: [How to Use The CDS API](https://cds-beta.climate.copernicus.eu/how-to-api).

```bash
nano $HOME/.cdsapirc
# Paste in your {uid} and {api-key} 
```

## Configuration
This pipeline revolves around the `ENVS` file to provide the necessary configuration items. This can easily be derived from the `ENVS.example` file to a new file, then symbolically linked. Comments are available in `ENVS.example` to assist you with the editing process.
```bash
cp ENVS.example ENVS.myconfig
ln -sf ENVS.myconfig ENVS
# Edit ENVS.myconfig to customise parameters for the pipeline
```

Please inspect this file when running the pipeline for the first time. In particular `$FIRST_RUN` might prevent you from succesfully running the pipeline when set to `false` on first run.

## Citation
If you use this pipeline in your work, please cite this repository by using the 'Cite this repostory' button on the top right of this repository.

## Acknowledgements
This work used JASMIN, the UK’s collaborative data analysis environment (https://www.jasmin.ac.uk).

The `asli` package uses data from Hersbach, H. et al., (2018) downloaded from the Copernicus Climate Change Service (2023). This software is used to download the data. Therefore these sources are cited below without a specific access date.

## References
Brown, M. J., & Chevuturi, A. object_store_tutorial [Computer software]. https://github.com/NERC-CEH/object_store_tutorial

Byrne, J., Ubald, B. N., & Chan, R. icenet-pipeline (Version v0.2.9) [Computer software]. https://github.com/icenet-ai/icenet-pipeline

Copernicus Climate Change Service (2023): ERA5 hourly data on single levels from 1940 to present. Copernicus Climate Change Service (C3S) Climate Data Store (CDS), DOI: 10.24381/cds.adbb2d47.

Hersbach, H., Bell, B., Berrisford, P., Biavati, G., Horányi, A., Muñoz Sabater, J., Nicolas, J., Peubey, C., Radu, R., Rozum, I., Schepers, D., Simmons, A., Soci, C., Dee, D., Thépaut, J-N. (2018): ERA5 hourly data on single levels from 1940 to present. Copernicus Climate Change Service (C3S) Climate Data Store (CDS), DOI: 10.24381/cds.adbb2d47.

Hosking, J. S., A. Orr, T. J. Bracegirdle, and J. Turner (2016), Future circulation changes off West Antarctica: Sensitivity of the Amundsen Sea Low to projected anthropogenic forcing, Geophys. Res. Lett., 43, 367–376, doi:10.1002/2015GL067143.

Hosking, J. S., & Wilby, D. asli [Computer software]. https://github.com/scotthosking/amundsen-sea-low-index

Lawrence, B. N. , Bennett, V. L., Churchill, J., Juckes, M., Kershaw, P., Pascoe, S., Pepler, S., Pritchard, M. and Stephens, A. (2013) Storing and manipulating environmental big data with JASMIN. In: IEEE Big Data, October 6-9, 2013, San Francisco.

