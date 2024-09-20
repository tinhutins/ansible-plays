#!/bin/bash

source /opt/setEnv.sh

# Connect to postgres server with repmgr user and create a table named test
psql -h $node -U repmgr -d repmgr -c "CREATE TABLE test (id serial primary key, data varchar(255));"

# Check if the table is created
table_check=$(psql -h $node -U repmgr -d repmgr -tAc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'test');")

if [ "$table_check" == "t" ]; then
    echo "Table created successfully."

    # Drop the table
    psql -h $node -U repmgr -d repmgr -c "DROP TABLE test;"

    # Check if the table is dropped
    table_check=$(psql -h $node -U repmgr -d repmgr -tAc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'test');")

    if [ "$table_check" == "f" ]; then
        echo "Table dropped successfully."
        echo "All tests ran successfully. Postgresql is working properly"
        exit 0 # return 0 indicating success
    else
        echo "Error dropping table. Failover should be initiated !"
        exit 1 # return 1 indicating failure
    fi
else
    echo "Error creating table. Failover should be initiated !"
    exit 1 # return 1 indicating failure
fi