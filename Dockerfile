FROM python:latest
# FROM python@sha256:c5f60863db103c951595f110def9244c1e09efe9e8d072cfac3da39310bc8cc8

# install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends zip unzip curl postgresql-client build-essential jq

# Install Geosupport
ARG RELEASE=22a1
ARG MAJOR=22
ARG MINOR=11
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

RUN curl -sSL https://install.python-poetry.org | python3 -

RUN . $HOME/.local/bin\
    poetry config virtualenvs.create false --local;\
    poetry install --no-dev

ENV PATH="~/.local/bin:$PATH"
