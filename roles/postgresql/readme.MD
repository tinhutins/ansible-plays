install postgresql in HA mode

run this plays : 

```bash
    ansible-playbook -i inventory/inventory_postgresql.ini preinstall.yml --tags provision -kK
    ansible-playbook -i inventory/inventory_postgresql.ini postinstall.yml --tags install_postgresql_ha
```
