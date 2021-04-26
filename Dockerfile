FROM python:3.9-slim

# install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends unzip curl postgresql-client-11 build-essential jq

# Install Geosupport
ARG RELEASE=21a
ARG MAJOR=21
ARG MINOR=1
ARG PATCH=0

WORKDIR /geosupport
RUN FILE_NAME=linux_geo${RELEASE}_${MAJOR}_${MINOR}.zip\
    && echo $FILE_NAME\
    && curl -O https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/$FILE_NAME\
    && unzip -qq *.zip\
    && rm *.zip

ENV GEOFILES=/geosupport/version-${RELEASE}_${MAJOR}.${MINOR}/fls/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/geosupport/version-${RELEASE}_${MAJOR}.${MINOR}/lib/

# Copy files and poetry install
WORKDIR /src
COPY . .

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

RUN --mount=type=cache,target=/root/.cache\
    . $HOME/.poetry/env;\
    poetry config virtualenvs.create false --local;\
    poetry install --no-dev

ENV PATH="~/.local/bin:$PATH"
