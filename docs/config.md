# Configuration
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