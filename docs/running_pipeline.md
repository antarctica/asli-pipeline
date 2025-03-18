# Running the pipeline manually
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

First, make `run_asli_pipeline.sh` executable with `chmod +x run_asli_pipeline.sh`. Also remember to do this after every pull `run_asli_pipeline.sh` has changes.


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
sbatch -p rocky -A rocky -t 00:30 -D /users/USERNAME/asli-pipeline -o /data/hpcdata/users/USERNAME/out/asli_run.%j.%N.out -e /data/hpcdata/users/USERNAME/out/asli_run.%j.%N.err run_asli_pipeline.sh
```

## Managing crontab and scrontab
Below is a cron example of the entire pipeline running once a month on the BAS HPC:

```bash
0 3 1 * * source /etc/profile.d/modules.sh; module load mamba/r-4.3; cd $HOME/asli-pipeline; src/00_download_era5.sh && run_asli_pipeline.sh; deactivate
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
