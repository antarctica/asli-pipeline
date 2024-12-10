from rocrate.rocrate import ROCrate
from rocrate.model.person import Person
from rocrate.model.softwareapplication import SoftwareApplication
from rocrate.model.entity import Entity

from datetime import datetime
from rdflib import *

crate = ROCrate()

data_input = crate.add_dataset("data/", properties={
    "name":"ERA5 Data",
    "type":"File",
    "encodingFormat":"application/netcdf"
})

pipeline_configuration = crate.add_file("ENVS", properties={
    "name":"Pipeline Configuration File",
    "type":"File"
})

data_output = crate.add_dataset("output/", properties={
    "name": "ASL Calculations",
    "encodingFormat": "text/csv",
    "datePublished": Literal(datetime.now().isoformat)
})

# python_package = crate.add_file("https://github.com/davidwilby/amundsen-sea-low-index", properties ={
#     "name": "amundsen-sea-low-index",
#     "type": ["File", "SoftwareSourceCode"],
#     "programming_language" : {"@id" : "https://www.python.org/downloads/release/python-380/"},
#     "url":"https://github.com/davidwilby/amundsen-sea-low-index"
# })

pipeline_scripts = crate.add_directory("src/", properties={
    "name":"pipeline scripts",
    "type":["File", "SoftwareSourceCode"],
    "url":"https://github.com/antarctica/asli-pipeline"
})

pipeline =  crate.add_file("run_asli_pipeline.sh", properties={
    "name":"asli-pipeline",
    "type":["File", "SoftwareSourceCode", "ComputationalWorkflow"],
    "url":"https://github.com/antarctica/asli-pipeline"
})

# Programming Languages
python_pl = crate.add(Entity(crate, properties={
    "@id": "#python",
    "@type": "ProgrammingLanguage",
    "url":"https://www.python.org/downloads/release/python-380/",
    "version":""
}))

r_pl = crate.add(Entity(crate, properties={
    "@id":"#R",
    "@type": "ProgrammingLanguage",
    "url": "",
    "version":""
}))

bash_pl = crate.add(Entity(crate, properties={
    "@id":"#bash",
    "@type": "ProgrammingLanguage",
    "url":"",
    "version":""
}))

# External Software Packages
asli_package = crate.add(SoftwareApplication(crate, properties={
    "name": "asli",
    "type": ["File", "SoftwareSourceCode"],
    "url":"https://github.com/davidwilby/amundsen-sea-low-index"
}))

butterfly_package = crate.add(SoftwareApplication(crate, properties={
    "name":"butterfly",
    "type": ["File", "SoftwareSourceCode"],
    "url":"https://github.com/antarctica/butterfly"
}))

# Authors
david_id = ""
scott_id = ""
thomas_id = ""

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

# Defining relationships
# Assigning authors
data_output["author"] = scott
pipeline["author"] = thomas
pipeline_scripts["author"] = thomas
asli_package["author"] = [david, thomas]

# Assigning programming languages
pipeline_scripts["programming_language"] = [python_pl, bash_pl]
asli_package["programming_language"] = python_pl
butterfly_package["programming_language"] = r_pl

# Define pipeline inputs and outputs
pipeline["input"] = [data_input, pipeline_configuration, asli_package]
pipeline["output"] = data_output


crate.write("asli_crate")