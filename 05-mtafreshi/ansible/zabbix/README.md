## Requirment:
### community.postgresql if does Not exist!~ .
```
ansible-galaxy collection install community.postgresql
``` 
### Please Configure 'cpath' for Access Ansible to vault.txt
```
inventory/group_vars/all.yaml 
```

## Run Ansible:
```
ansible-playbook -i inventory/hosts.ini main.yaml --become --become-method=sudo -J
```

Good Lock!~ .