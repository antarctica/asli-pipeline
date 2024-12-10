from rocrate.rocrate import ROCrate
from rocrate.model.person import Person
from datetime import datetime
from rdflib import *

crate = ROCrate()

data_input_lsm = crate.add_dataset("data/", properties={
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

python_package = crate.add_file("https://github.com/davidwilby/amundsen-sea-low-index", properties ={
    "name": "amundsen-sea-low-index",
    "type": ["File", "SoftwareSourceCode"],
    "programming_language" : {"@id" : "https://www.python.org/downloads/release/python-380/"},
    "url":"https://github.com/davidwilby/amundsen-sea-low-index"
})

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

data_output["author"] = scott
python_package["author"] = [david, thomas]
pipeline["author"] = thomas

crate.write("asli_crate")
