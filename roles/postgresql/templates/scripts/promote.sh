#!/bin/bash
# Location : /opt/promote.sh
# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a /var/log/repmgr/promote.log
}

log "Starting promotion..."
log "Stopping repmgrd service..."
sudo systemctl stop repmgrd
log "Promoting the standby to primary..."
sudo -u postgres repmgr standby promote -f /etc/repmgr.conf --log-to-file
sleep 2
log "Starting repmgrd service..."
sudo systemctl start repmgrd
sleep 2

# Check if promotion was successful
if [ $? -eq 0 ]; then
    echo "Node successfully promoted to primary."
    log "Node successfully promoted to primary."
else
    echo "Failed to promote node to primary."
    log "Failed to promote node to primary."
    exit 1
fi