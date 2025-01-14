## Requirment:
### community.postgresql if does Not exist!~ .
```
ansible-galaxy collection install community.postgresql
``` 

## Run Ansible:
```
ansible-playbook -i inventory/hosts.ini main.yaml --become --become-method=sudo -J
```

Good Lock!~ .