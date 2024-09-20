#!/bin/bash
# Configuration
REPMGR_CONFIG="/etc/repmgr.conf"
PRIMARY_CONNINFO="host={{ hostvars[groups['postgresql_cluster'][1]].ansible_default_ipv4.address }} dbname=repmgr user=repmgr"
LOGFILE="/var/log/repmgr/follow.log"
MAX_WAIT=30
RETRY_INTERVAL=5
RETRY_COUNT=5


# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}


log "Checking PostgreSQL status..."


# Check if the node is in recovery mode (standby)
IS_STANDBY=$(sudo -u postgres psql -h {{ansible_host}} -U repmgr -d repmgr -tAc "SELECT pg_is_in_recovery()")


if [ "$IS_STANDBY" == "t" ]; then
    log "Node is already standby, nothing to do."

else
    log "Node is primary, checking if it should be rejoined as standby."


    # Check if the node is registered as standby but running as primary
    NODE_STATUS=$(sudo -u postgres repmgr -f $REPMGR_CONFIG cluster show | grep -E 'running as primary' | grep -E 'standby')


    if [ -n "$NODE_STATUS" ]; then
        log "We have a node registered as a standby but running as primary which means it was promoted to primary. Correcting this node state to standby."

        log "Stopping PostgreSQL service..."
        sudo systemctl stop postgresql


        # Wait for PostgreSQL service to stop
        WAIT_TIME=0
        while systemctl is-active --quiet postgresql; do
            sleep 1
            WAIT_TIME=$((WAIT_TIME+1))
            if [ $WAIT_TIME -ge $MAX_WAIT ]; then
                log "PostgreSQL service did not stop within $MAX_WAIT seconds. Exiting rejoin process."
                exit 1
            fi
        done
        log "PostgreSQL service stopped successfully."


        sleep 6


        # Retry logic for repmgr node rejoin
        RETRY=0
        while [ $RETRY -lt $RETRY_COUNT ]; do
            log "Running repmgr node rejoin (attempt $((RETRY+1))/$RETRY_COUNT)..."
            sudo -u postgres repmgr node rejoin -f $REPMGR_CONFIG -d "$PRIMARY_CONNINFO" --force-rewind --config-files=postgresql.local.conf,postgresql.conf --verbose
            if [ $? -eq 0 ]; then
                log "Rejoin successful."
                break
            else
                log "Rejoin failed, retrying in $RETRY_INTERVAL seconds..."
                sleep $RETRY_INTERVAL
                RETRY=$((RETRY+1))
            fi
        done


        if [ $RETRY -eq $RETRY_COUNT ]; then
            log "Rejoin failed after $RETRY_COUNT attempts. Forcing PostgreSQL to start."
            sudo systemctl start postgresql
            sleep 6
        else
            log "Starting PostgreSQL service..."
            sudo systemctl start postgresql
            sleep 6
        fi


        log "Starting repmgrd service..."
        sudo systemctl restart repmgrd

        log "Follow script completed."
    else
        log "Node is primary, but no mismatch in status detected. No action required."
    fi
fi