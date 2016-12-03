#!/bin/bash
ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N ""
cp ~/.ssh/id_rsa ./export/azurekey
ansible-playbook -i inventory playbooks/init.yml
ansible-playbook --forks=50 -i invetory playbooks/install_openshift.yml
