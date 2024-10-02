install mongodb in HA mode (replicaset primary/secondary/arbiter)

run this plays : 

```bash
    ansible-playbook -i inventory/inventory_mongodb.ini preinstall.yml --tags provision -kK
    ansible-playbook -i inventory/inventory_mongodb.ini postinstall.yml --tags install_mongodb_rs
```
