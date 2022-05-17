import os

import yaml

metadata = {"datasets": []}


class MyDumper(yaml.Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(MyDumper, self).increase_indent(flow, False)


def add_version(dataset: str, version: str):
    metadata["datasets"].append({"name": dataset, "version": version})


def dump_metadata():
    if not os.path.exists("output/"):
        os.mkdir("output/")
    with open("output/metadata.yml", "w") as outfile:
        yaml.dump(metadata, outfile, Dumper=MyDumper, default_flow_style=False)
