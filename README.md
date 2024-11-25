# asli-pipeline
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

### Packages and Virtual Environments on JASMIN
If you are working on JASMIN, it is good to familiarise yourself with managing software environments on Jasmin:
   1. [Quick Start on software for JASMIN](https://help.jasmin.ac.uk/docs/software-on-jasmin/quickstart-software-envs/)
   2. [Python Virtual Environments for JASMIN](https://help.jasmin.ac.uk/docs/software-on-jasmin/python-virtual-environments/).

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

## Data Output
The pipeline allows data output to the JASMIN Object Store, a local file system, or both - depending on where you are running this pipeline and which output file formats you would like to use.

### Data Output to JASMIN Object Store
The pipeline uses `s3cmd` to interact with S3 compatible Object Storage. If you configure your data to be written out to the JASMIN Object Store, you will need to configure `s3cmd` to access your object storage tenancy and bucket.

You will need to generate an access key, and store it in a `~/.s3cfg` file. Full instructions on how to [generate an access key on JASMIN](https://help.jasmin.ac.uk/docs/short-term-project-storage/using-the-jasmin-object-store/#creating-an-access-key-and-secret) and an [s3cfg file](https://help.jasmin.ac.uk/docs/short-term-project-storage/using-the-jasmin-object-store/#using-s3cmd)  to use `s3cmd` are in the JASMIN documentation.

### Data Output to local file system
If you require data to be copied to a different location (e.g. the BAS SAN, for archival into the Polar Data Centre) you can configure this destination in `ENVS`. This will then `rsync` your output to that location.

## Running the pipeline manually
Before running the pipeline, make sure you have followed the steps above:
   1. Cloned the pipeline.
   2. Set up your environment.
   3. Installed `asli`.
   4. Set CDS API access with `.cdsapirc`.
   5. Set configurations `ENVS.myconfig` and symbolically linked to `ENVS`.
   6. Set configurations for the Object Store in `.s3cfg`.

You can now run the pipeline:
```bash
deactivate # Your environment is set in ENVS, so you do not need to call it

# Download the era5 data first
bash src/00_download_era5.sh

# Then run the whole pipeline
bash run_asli_pipeline.sh
```

## Automating the pipeline with cron
A cron example has been provided in the `cron.example` file.

```bash
crontab -e

# Then edit the file, for example to run once a month:
0 3 1 * * cd $HOME/asli-pipeline; src/00_download_era5.sh && run_asli_pipeline.sh; deactivate

# OR on JASMIN we are using crontamer:
0 3 1 * * crontamer -t 2h -e youremail@address.ac.uk 'cd gws/nopw/j04/dit/users/USERNAME/asli-pipeline; src/00_download_era5 && run_asli_pipeline.sh; deactivate'

# On the BAS HPC, you will likely need to load the software modules first as well:
0 3 1 * * source/etc/profile.d/modules.sh; module load mamba/r-4.3; cd $HOME/asli-pipeline; src/00_download_era5.sh && run_asli_pipeline.sh; deactivate
```
For more information on using cron on JASMIN, see [Using Cron](https://help.jasmin.ac.uk/docs/workflow-management/using-cron/) in the JASMIN documentation, and the [crontamer](https://github.com/cedadev/crontamer) package. The purpose of `crontamer` is to stop multiple process instances starting. It also times out after x hours and emails on error.

## A note on sbatch/SLURM
If you need to submit this pipeline to SLURM (for example [on JASMIN](https://help.jasmin.ac.uk/docs/batch-computing/how-to-submit-a-job/)), you will need to provide `sbatch` headers to the SLURM queue. We have not included sbatch headers in our script.

However, you can include `sbatch` headers when you call the executable script: 

```bash
# Downloading era5 data first, due to SLURM timeouts and CDS api response time
# it is recommended to not send this script as a job to SLURM
bash src/00_download_era5.sh

# Submitting a job to the short-serial partition on JASMIN
sbatch -p short-serial -t 03:00 -o job01.out -e job01.err run_asli_pipeline.sh`
```

On the BAS HPC, remember to set the working directory. For example:

```bash
# On the rocky machine, otherwise 'rocky' becomes 'short'
sbatch -p rocky -A rocky -t 00:30 -D /users/USERNAME/asli-pipeline -o /data/hpcdata/users/USERNAME/out/asli_run.%i.%N.out -e /data/hpcdata/users/USERNAME/out/asli_run.%i.%N.err ./run_asli_pipeline.sh
```

## Managing crontab and scrontab
Below is a cron example of the entire pipeline running once a month on the BAS HPC:

```bash
0 3 1 * * source /etc/profile.d/modules.sh; module load mamba/r-4.3; cd $HOME/asli-pipeline; src/00_download_era5.sh && ./run_asli_pipeline.sh; deactivate
```

When running the calculations on the entire dataset, this can take up a bit of memory. Ideally we send the processing to SLURM, however this is not possible with the downloading process, as it may take the CDS API too long to respond.

Therefore we set up a crontab to **only download the data**, running locally, and a [scrontab](https://slurm.schedmd.com/scrontab.html), to send the **processing** to SLURM.

Calling only the downloading script, on the first of the month at 1am:

```bash
crontab -e
0 1 1 * * source /etc/profile.d/modules.sh; module load mamba/r-4.3; cd /users/thozwa/asli-pipeline; src/00_download_era5.sh
```
Sending the processing pipeline to SLURM on the first of the month at 5am:

```bash
scrontab -e

# Then edit the script as follows:
#SCRON --partition=rocky
#SCRON --account=rocky
#SCRON --time=00:45:00
#SCRON --output=/data/hpcdata/users/USERNAME/out/asli_run.%j.%N.out
#SCRON --error=/data/hpcdata/users/USERNAME/out/asli_run.%j.%N.err
#SCRON --chdir=/users/USERNAME/asli-pipeline
0 5 1 * * source /etc/profile.d/modules.sh && module load mamba/r-4.3 && run_asli_pipeline.sh
```
A SLURM cron example has been provided in the `scron.example` file.

Combining crontab and scrontab to perform the entire pipeline once a month, in the most computationally-friendly way possible.

## Deployment Example
The following describes an example deployment setup for this pipeline. This was done under the BOOST-EDS project.

We are using a [JASMIN](https://jasmin.ac.uk/) group workspace (GWS) to run a data processing pipeline. Using the [Copernicus Climate Data Store API](https://cds.climate.copernicus.eu/#!/home), ERA5 data is read in. Calculations are then performed on [LOTUS](https://help.jasmin.ac.uk/docs/batch-computing/lotus-overview/) using `asli` functions.Output data is stored on [JASMIN Object Storage](https://help.jasmin.ac.uk/docs/short-term-project-storage/using-the-jasmin-object-store/). This data is read in and displayed by this application. This application in turn is [hosted on Datalabs](https://datalab.datalabs.ceh.ac.uk/). 

![](img/asli-technical-overview.png)

This means compute, data storage and application hosting are all separated. 

### Portability
Each component listed above could also be deployed on different suitables infrastructures, for example BAS HPCs or commercial cloud providers.

## Interaction with Datalabs
The results of this pipeline are displayed in an [application hosted on Datalabs](https://ditbas-asliapp.datalabs.ceh.ac.uk/).

Follow this [tutorial to see how Datalabs and the JASMIN Object Store interact](https://github.com/NERC-CEH/object_store_tutorial/tree/main).

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

