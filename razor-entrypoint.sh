#!/bin/sh

echo "Starting PostgreSQL"
su postgres -c 'postgres -D /var/lib/pgsql/data -p 5432 2>&1 &'
echo "done!"


echo "Configuring DB in Razor - config.yml"
sed -i -e 's/razor_prd/razor/' -e 's/mypass/System12/g' /etc/razor/config.yaml


echo "Setting up Razor Microkernal"
curl -SL http://links.puppetlabs.com/razor-microkernel-latest.tar | tar -xC /var/lib/razor/repo-store/
echo "Microkernal is at /var/lib/razor/repo-store   -   Comment this line after the initial run!!!"

echo "populating razor DB schema"
razor-admin -e production migrate-database
echo "Razor Database schema populated successfully"


echo "Starting Razor Server"
/opt/razor-torquebox/jboss/bin/standalone.sh -Djboss.server.log.dir=/var/log/razor-server -Dhttp.port=8150 -Dhttps.port=8151  -b 0.0.0.0 

