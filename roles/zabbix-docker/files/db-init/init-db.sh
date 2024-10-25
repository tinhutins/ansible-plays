#!/bin/bash

# Unzip the .gz SQL file and load it into the database
echo "Unzipping and loading SQL dump into the database..."
zcat /tmp/create.sql.gz | mysql -u"root" -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"
