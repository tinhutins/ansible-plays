export user='postgres'
export node='{{ansible_host}}'
export othernode='{{ hostvars[groups['postgresql_cluster'][1]].ansible_default_ipv4.address }}'