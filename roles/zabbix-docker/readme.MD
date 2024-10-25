We install latest available zabbix 7.0.5 as of the time of writing 22 October 2024.

ansible-vault password is: 
```bash
    password
```

provision VM, add docker and docker-compose:
```bash
    ansible-playbook -i inventory/inventory_all.ini preinstall.yml --tags provision -kK
    ansible-playbook -i inventory/inventory_zabbix_docker.ini postinstall.yml --tags install_docker_docker_compose --ask-vault-pass
```

install zabbix-nginx,zabbix-server-mysql,and mysql:
```bash
    ansible-playbook -i inventory/inventory_zabbix_docker.ini postinstall.yml --tags install_zabbix_docker --ask-vault-pass
```

Go to (https://VM_IP), or https://DNS_hostname that resolvs to this VM IP (also optionally upload rootCA to browser to avoid ssl warnings for this self-signed crt)

default username and password for zabbix:
```bash
    username: Admin
    password: zabbix
```
