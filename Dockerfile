FROM centos
MAINTAINER Muhammed Iqbal   iquzart@hotmail.com

COPY ./razor-entrypoint.sh /etc/razor/razor-entrypoint.sh

RUN yum update -y && \
    yum -y install sudo epel-release && \
    yum install -y \
    http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm \
    wget \
    ruby \
    rubygems \
    postgresql-server \
    postgresql \
    supervisor \
    postgresql-contrib \
    pwgen && \ 
    yum install -y razor-server

ADD ./postgresql-setup /usr/bin/postgresql-setup


#Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers
RUN chmod +x /usr/bin/postgresql-setup

RUN /usr/bin/postgresql-setup initdb

ADD ./postgresql.conf /var/lib/pgsql/data/postgresql.conf
RUN chown -v postgres.postgres /var/lib/pgsql/data/postgresql.conf    

RUN  rm -f /var/lib/pgsql/data/pg_hba.conf
COPY ./pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
RUN chown -v postgres.postgres /var/lib/pgsql/data/postgresql.conf

#--------------------------------------------------------#
# 		Razor Database Setup			 #
#--------------------------------------------------------#
ENV DB_NAME razor
ENV DB_USER razor
ENV DB_PASS "System12"
ENV PG_CONFDIR "/var/lib/pgsql/data"


RUN echo "CREATE ROLE ${DB_USER} with CREATEROLE login superuser PASSWORD '${DB_PASS}';" | \
      sudo -u postgres -H postgres --single \
       -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}


RUN echo "CREATE DATABASE ${DB_NAME};" | \
    sudo -u postgres -H postgres --single \
     -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}

RUN  echo "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};" | \
      sudo -u postgres -H postgres --single \
      -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}
#------------------------------------------------------------#

VOLUME /var/lib/pgsql

RUN gem install razor-client

EXPOSE 5432 8150

CMD ["/bin/bash", "/etc/razor/razor-entrypoint.sh" ]
