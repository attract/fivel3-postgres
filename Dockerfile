FROM postgres:9.5
MAINTAINER AttractGroup

ADD ./create_hstore.sql /docker-entrypoint-initdb.d