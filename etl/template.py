from dataflows import load, Flow, printer, find_replace
from dataflows import add_field, add_computed_field, filter_rows
from lib import dump_to_postgis, rename_field
import os
import csv
import sys
from pathlib import Path
import re
from utils import url

csv.field_size_limit(sys.maxsize)
table_name = 'dcas_colp'
dcas_colp = Flow(
    load(url, resources = table_name, force_strings=False),
    checkpoint(table_name),
    # uid text,
    # facname text,
    # factype text,
    # facsubgrp text,
    # facgroup text,
    # facdomain text,
    # servarea text,
    # opname text,
    # opabbrev text,
    # optype text,
    # overagency text,
    # overabbrev text,
    # overlevel text,
    # capacity text,
    # captype text,
    # proptype text,
    # datasource
    # hnum text,
    # sname text,
    # address text,
    # city text,
    # zipcode text,
    # boro text,
    # bin text,
    # bbl text,
    # latitude text,
    # longitude text,
    # xcoord text,
    # ycoord text,
    # commboard text,
    # nta text,
    # council text,
    # censtract text,
    # geom text
    printer(num_rows=3)      
)

dohmh_daycare.process()

