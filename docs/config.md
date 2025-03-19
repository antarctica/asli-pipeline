# Configuration
This pipeline revolves around the `ENVS` file to provide the necessary configuration items. This can easily be derived from the `ENVS.example` file to a new file, then symbolically linked. Comments are available in `ENVS.example` to assist you with the editing process.
```bash
cp ENVS.example ENVS.myconfig
ln -sf ENVS.myconfig ENVS
# Edit ENVS.myconfig to customise parameters for the pipeline
```

Please inspect this file when running the pipeline for the first time. In particular `$FIRST_RUN` might prevent you from succesfully running the pipeline when set to `false` on first run.

## ENVS Parameters
The `ENVS` file contains the parameters which control the pipeline. An example is provided in `ENVS.example`:

### Project Setup
These parameters are provided to set up the project's folders and environment:

* **PIPELINE_DIRECTORY**: The directory you are running the pipeline in.
* **DATA_DIR**: The directory ERA5 monthly data should be donwloaded to.
* **OUTPUT_DIR**: The directory ASLI calculation output should be written to.
* **ASLI_VENV**:  The location of the project's virtual environment.
* **CURRENT_DATE**: Current date, no need to change.
* **CURRENT_YEAR**: Current year, no need to change.

### Run Configuration
These parameters are provided to configure how the pipeline should run:

* **EXPORT_ROCRATE**: Should the pipeline generate an RO-Crate object. Should be one of true/false.
* **NUM_CORES**: Number of parallel jobs to run the pipeline with.
* **FIRST_RUN**: Is this the first run? Should be one of true/false. Setting this to true will prevent the pipeline from running verification checks against a file that does not exist yet.

### File Export
These parameters are provided to determine file export:

* **FILE_DESTINATION**: What type of file storage should the ASLI calculation be export to? One of `OBJECT_STORAGE`, `FILE_SYSTEM` or `BOTH`
* **VALID_DESTINATIONS**: A list of valid destinations (`OBJECT_STORAGE`, `FILE_SYSTEM`, `BOTH`). No need to change.
* **S3_BUCKET**: If `FILE_DESTINATION` is `OBJECT_STORAGE` or `BOTH`, the S3 bucket endpoint to export ASLI calculation results to.
* **RSYNC_LOCATION**: If `FILE_DESTINATION` is `FILE_SYSTEM` or `BOTH`, the file path to export ASLI calculation results to.
* **FILE_IDENTIFIER**: A unique identifier for the ASLI calculation output file.

### Data Request
These parameters control the data request that is submitted to the CDS API:

* **START_YEAR**: The first year to request.
* **END_YEAR**: The last year to request.
* **DATA_ARGS_ERA5**: The full request submitted to the CDS API (e.g. `"-s ${START_YEAR} -n ${CURRENT_YEAR}"`). Additional arguments can be provided.

### Quality Control
These parameters control quality control values:

* **SD_FROM_MEAN**: Standard deviations from the mean, to check no values lie outwith `SD_FROM_MEAN`.
* **ACTCENPRES_BOUNDS_MIN**: Minimum value (in hPA) we expect actual_central_pressure to be above.
* **ACTCENPRES_BOUNDS_MAX**: Maximum value (in hPA) we expect actual_central_pressure to be below.


## Data Output
The pipeline allows data output to the JASMIN Object Store, a local file system, or both - depending on where you are running this pipeline and which output file formats you would like to use.

### Data Output to JASMIN Object Store
The pipeline uses `s3cmd` to interact with S3 compatible Object Storage. If you configure your data to be written out to the JASMIN Object Store, you will need to configure `s3cmd` to access your object storage tenancy and bucket.

You will need to generate an access key, and store it in a `~/.s3cfg` file. Full instructions on how to [generate an access key on JASMIN](https://help.jasmin.ac.uk/docs/short-term-project-storage/using-the-jasmin-object-store/#creating-an-access-key-and-secret) and an [s3cfg file](https://help.jasmin.ac.uk/docs/short-term-project-storage/using-the-jasmin-object-store/#using-s3cmd)  to use `s3cmd` are in the JASMIN documentation.

### Data Output to local file system
If you require data to be copied to a different location (e.g. the BAS SAN, for archival into the Polar Data Centre) you can configure this destination in `ENVS`. This will then `rsync` your output to that location.