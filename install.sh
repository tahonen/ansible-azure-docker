#!/bin/bash
ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N ""
touch ~/.ssh/known_hosts
cp ~/.ssh/id_rsa ./export/azurekey.$(grep  '^resource_group_name:' /ansible-azure/group_vars/all | awk '{ print $2}')
#o#ansible-playbook -i inventory playbooks/init.yml
sed -i "/sshkey: /c\sshkey: $(cat /root/.ssh/id_rsa.pub)" /ansible-azure/group_vars/all
ansible-playbook --forks=50 -i bla  playbooks/setupeverything.yml
