FROM postgres:9.5
MAINTAINER AttractGroup

RUN apt update

# install pg-sphinx
ADD ./pg-sphinx /pg-sphinx
RUN apt install -y build-essential
RUN apt install -y postgresql-server-dev-9.5
RUN apt install -y libmysqlclient-dev

WORKDIR /pg-sphinx
RUN make && make install

# Add extensions
ADD ./create_hstore.sql /docker-entrypoint-initdb.d
#ADD ./triggers.sql /docker-entrypoint-initdb.d