install rancher server v1.6 and rancher worker node
on both servers run this plays : 

```bash
    ./install.sh
    ansible-playbook -i inventory/inventory_all.ini preinstall.yml --tags provision -kK
    ansible-playbook -i inventory/inventory_all.ini postinstall.yml --tags install_older_docker
```

for rancher server also run : 
```bash
ansible-playbook -i inventory/inventory_all.ini postinstall.yml --tags install_docker_server_non_ha
```

then after creating rancher server manually through UI add rancher worker.
 1. in UI create new env 
 2. generate cmd to add docker worker 
 3. run that command on worker node