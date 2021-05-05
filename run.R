library(future.batchtools)
future::plan(batchtools_sge(template = "sge_batchtools.tmpl"))
future(system2("hostname"), resources = list(slots = 2))
