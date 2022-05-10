import json
from functools import wraps

import pandas as pd
from tqdm.contrib.concurrent import process_map

from . import GeosupportError, g


class Function1A:
    def __init__(
        self,
        street_name_field: str = None,
        house_number_field: str = None,
        borough_field: str = None,
        zipcode_field: str = None,
    ):
        self.street_name_field = street_name_field
        self.house_number_field = house_number_field
        self.borough_field = borough_field
        self.zipcode_field = zipcode_field

    def geocode_a_dataframe(self, df: pd.DataFrame):
        records = df.to_dict("records")
        it = process_map(self.geocode_one_record, records, chunksize=1000)
        df_geo = pd.DataFrame(it)
        return df.merge(df_geo, how="left", on="uid", suffixes=("", "_"))

    def geocode_one_record(self, inputs: dict) -> dict:
        """
        Note that df needs
        """
        uid = inputs.get("uid")
        input_sname = inputs.get(self.street_name_field)
        input_hnum = inputs.get(self.house_number_field)
        input_borough = inputs.get(self.borough_field)
        input_zipcode = inputs.get(self.zipcode_field)
        print(
            f"passing these inputs to 1A \
            {input_sname=}, {input_hnum=}, {input_borough=}, {input_zipcode=}"
        )
        try:
            geo = g["1A"](
                street_name=input_sname,
                house_number=input_hnum,
                borough=input_borough,
                zip_code=input_zipcode,
            )
        except GeosupportError as e:
            geo = e.result

        geo = self.parser(geo)
        print(f"result is {geo}")
        return dict(
            uid=uid,
            geo_1a=json.dumps(
                dict(
                    inputs=dict(
                        input_sname=input_sname,
                        input_hnum=input_hnum,
                        input_borough=input_borough,
                        input_zipcode=input_zipcode,
                    ),
                    result=geo,
                )
            ),
        )

    def parser(self, geo):
        return dict(
            geo_house_number=geo.get("House Number - Display Format", None),
            geo_street_name=geo.get("First Street Name Normalized", None),
            geo_borough_code=geo.get("BOROUGH BLOCK LOT (BBL)", {}).get(
                "Borough Code", None
            ),
            geo_zip_code=geo.get("ZIP Code", None),
            geo_bin=geo.get(
                "Building Identification Number (BIN) of Input Address or NAP", None
            ),
            geo_bbl=geo.get("BOROUGH BLOCK LOT (BBL)", {}).get(
                "BOROUGH BLOCK LOT (BBL)", None
            ),
            geo_latitude=geo.get("Latitude", None),
            geo_longitude=geo.get("Longitude", None),
        )

    def __call__(self, func):
        def wrapper(*args, **kwargs):
            df = func()
            df = self.geocode_a_dataframe(df)
            return df

        return wrapper
