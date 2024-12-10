from rocrate.rocrate import ROCrate
from rocrate.model.person import Person
from rocrate.model.softwareapplication import SoftwareApplication
from rocrate.model.entity import Entity

import sys
import platform
import json 

from datetime import datetime
from rdflib import *

# Initialise ROCrate
crate = ROCrate()

# Read in renv.lock for software version information
with open('renv.lock') as f:
    renv_lock = json.load(f)

data_input = crate.add_dataset("data/", "data", properties={
    "name":"ERA5 Data",
    "description":"Folder containing ERA5 land sea mask (era5_lsm.nc) and ERA5/monthly/era5_mean_sea_level_pressure_monthly* files.",
    "type":"FormalParameter",
    "valueRequired":True,
    "encodingFormat":"application/netcdf"
})

pipeline_configuration = crate.add_file("ENVS", properties={
    "name":"Pipeline Configuration File",
    "type":"FormalParameter",
    "valueRequired":True,
})

data_output = crate.add_dataset("output/", "output", properties={
    "name": "ASL Calculations",
    "type": "FormalParameter",
    "encodingFormat": "text/csv",
    "datePublished": Literal(datetime.now().isoformat)
})

pipeline_scripts = crate.add_directory("src/", "src", properties={
    "name":"pipeline scripts",
    "type":["File", "SoftwareSourceCode"],
    "url":"https://github.com/antarctica/asli-pipeline"
})

pipeline =  crate.add_file("run_asli_pipeline.sh", properties={
    "name":"ASLI Pipeline",
    "description":"Pipeline using asli python package to calculate ASL Indices",
    "type":["File", "SoftwareSourceCode", "ComputationalWorkflow"],
    "url":"https://github.com/antarctica/asli-pipeline"
})


# Programming Languages
python_version_formatted = str(sys.version_info[0]) + str(sys.version_info[1]) + str(sys.version_info[2])

python_pl = crate.add(Entity(crate, "Python", properties={
    "@id": "#python",
    "@type": "ProgrammingLanguage",
    "url":["https://www.python.org/release/python-" + python_version_formatted + "/"],
    "version":platform.python_version()
}))

r_pl = crate.add(Entity(crate, "R", properties={
    "@type": "ProgrammingLanguage",
    "url": ["https://cran.r-project.org/src/base/R-4/R-" + renv_lock["R"]["Version"] + ".tar.gz"],
    "version": renv_lock["R"]["Version"]

}))

bash_pl = crate.add(Entity(crate, "bash", properties={
    "@id":"#bash",
    "@type": "ProgrammingLanguage",
    "url":"",
    "version":""
}))

# External Software Packages
asli_package = crate.add(SoftwareApplication(crate, "asli_package", properties={
    "name": "asli",
    "type": ["File", "SoftwareSourceCode"],
    "url":"https://github.com/davidwilby/amundsen-sea-low-index",
    "version": sys.argv[1]
}))

butterfly_package = crate.add(SoftwareApplication(crate, "butterfly_package", properties={
    "name":"butterfly",
    "type": ["File", "SoftwareSourceCode"],
    "url":"https://github.com/antarctica/butterfly",
    "version":renv_lock["Packages"]["butterfly"]["Version"]
}))

# Authors
david_id = "https://orcid.org/0000-0002-6553-8739"
scott_id = "https://orcid.org/0000-0002-3646-3504"
thomas_id = "https://orcid.org/0009-0003-3742-3234"

david = crate.add(Person(crate, david_id, properties={
    "name": "David Wilby",
    "affiliation": "British Antarctic Survey"
}))

scott = crate.add(Person(crate, scott_id, properties={
    "name": "Scott Hosking",
    "affiliation": "British Antarctic Survey"
}))

thomas = crate.add(Person(crate, thomas_id, properties={
    "name": "Thomas Zwagerman",
    "affiliation": "British Antarctic Survey"
}))

# Defining relationships between entities
# Assigning authors
data_output["author"] = scott
pipeline["author"] = thomas
pipeline_scripts["author"] = thomas
asli_package["author"] = [david, thomas]
butterfly_package["author"] = thomas

# Assigning programming languages
pipeline_scripts["programming_language"] = [python_pl, bash_pl, r_pl]
asli_package["programming_language"] = python_pl
butterfly_package["programming_language"] = r_pl

# Define pipeline inputs and outputs
pipeline["input"] = [data_input, pipeline_configuration, asli_package, butterfly_package, pipeline_scripts]
pipeline["output"] = data_output

crate.write("asli_crate")