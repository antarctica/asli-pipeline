# boost-eds-pipeline
This repository contains a pipeline for operational execution of the Amundsen Sea Ice Low calculations, provided in the `asli` package. The functions in the `asli` package are described in detail in the [package repository](https://github.com/davidwilby/amundsen-sea-low-index) `amundsen-sea-low-index`.

## Get the repository
Clone this repository into a directory on your computer or HPC.
```
git clone git@github.com:antarctica/boost-eds-pipeline.git asli
```

## Creating an environment
```bash
python -m venv aslienv

source aslienv/bin/activate
```

### Packages and Virtual Environments on JASMIN
If you are working on JASMIN, it is good to familiarise yourself with managing software environments on Jasmin:
    * [Quick Start on software for JASMIN](https://help.jasmin.ac.uk/docs/software-on-jasmin/quickstart-software-envs/).
    * [Python Virtual Environments for JASMIN](https://help.jasmin.ac.uk/docs/software-on-jasmin/python-virtual-environments/).

## Download the `asli` package
Install the `asli` package from Github using pip: `pip install git+https://github.com/davidwilby/amundsen-sea-low-index`, as per the instructions in the `amundsen-sea-low-index` [repository](https://github.com/davidwilby/amundsen-sea-low-index).

## Setting up Climate Data Store API
The `asli` package will not be able to download ERA5 data without access to the [Copernicus Climate Data Store](https://cds.climate.copernicus.eu/cdsapp#!/home).

Follow these instructions to set up CDS API access: [How to Use The CDS API](https://cds.climate.copernicus.eu/api-how-to).

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

### Data Output to JASMIN Object Store
The pipeline uses `s3cmd` to  interact with S3 compatible Object Storage. If you configure your data to be written out to the JASMIN Object Store, you will need to configure `s3cmd` to access your object storage tenancy and bucket.

You will need to generate an access key, and store it in a `~/.s3cfg` file. Full instructions on how to [generate an access key on JASMIN](https://help.jasmin.ac.uk/docs/short-term-project-storage/using-the-jasmin-object-store/#creating-an-access-key-and-secret) and an [s3cfg file](https://help.jasmin.ac.uk/docs/short-term-project-storage/using-the-jasmin-object-store/#using-s3cmd)  to use `s3cmd` are in the JASMIN documentation.

## Interaction with Datalabs
The results of this pipeline are displayed in an [application hosted on Datalabs](https://ditbas-asliapp.datalabs.ceh.ac.uk/).

Follow this [tutorial to see how Datalabs and the JASMIN Object Store interact](https://github.com/NERC-CEH/object_store_tutorial/tree/main).

## Running the pipeline manually


## Automating the pipeline cron

## Citation
If you use this pipeline in your work, please cite this repository by using the 'Cite this repostory' button on the top right of this repository.

>

## References
Brown, M. J., & Chevuturi, A. object_store_tutorial [Computer software]. https://github.com/NERC-CEH/object_store_tutorial

Hosking, J. S., A. Orr, T. J. Bracegirdle, and J. Turner (2016), Future circulation changes off West Antarctica: Sensitivity of the Amundsen Sea Low to projected anthropogenic forcing, Geophys. Res. Lett., 43, 367–376, doi:10.1002/2015GL067143.

Hosking, J. S., & Wilby, D. asli [Computer software]. https://github.com/scotthosking/amundsen-sea-low-index