# on prod server postgres:9.5.10, this code installing postgres:9.5.20 - it may be difference for working with HstoreField
FROM postgres:9.5
MAINTAINER AttractGroup

RUN apt update

# install pg-sphinx
ADD ./pg-sphinx /pg-sphinx
RUN apt install -y build-essential
RUN apt install -y postgresql-server-dev-9.5
RUN apt install -y default-libmysqlclient-dev
# default-libmysqlclient-dev

WORKDIR /pg-sphinx
RUN make && make install

# install plpython
RUN apt install -y postgresql-plpython-9.5
RUN apt install -y python-psycopg2

# install pip
RUN apt install -y python-pip
RUN apt install -y build-essential python-dev default-libmysqlclient-dev
# default-libmysqlclient-dev
RUN pip install MySQL-python==1.2.5

# Add extensions
ADD ./create_hstore.sql /docker-entrypoint-initdb.d
#ADD ./triggers.sql /docker-entrypoint-initdb.d
