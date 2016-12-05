# Deploying Openshift Enterprise to Azure with container
Simple project to help installing HA setup of Openshift Enterprise to Azure. Installer will use https://github.com/ivanthelad/ansible-azure project to do actually installation.

Installation is done with Docker container and environmental variables that are passed to docker run command. This project is just a wrapper to actual OSE installation so check more info about the installation from above link.

## What you need to for the installation
* Azure AD account
* Enough quota for cores (by default 7 VMs )
* Red Hat account and Openshift Enterprise subscription
* Docker

## Sample ALL config
The following configs are required

* resource_group_name: ivancloud     [This should be unique name ]

* ad_password: XXXXXXXXXXXXXXXXXXX   [Ansible User for azure ]

* subscriptionID: XXXXXXXXXXXXXX     [Ansible pwd for azure ]

* adminUsername: ivan                [User to log into jumphost with ]

* adminPassword: XXx_please_change_me_xXX  [User pwd to log into jumphost with ]

* rh_subcription_user: XXXXXXXXXXX   [RH subscription user ]

* rh_subcription_pass: XXXXXXXXXXX   [RH subscription pwd ]

* openshift_pool_id: XXXXXXXXXXX     [RH subscription pwd ]

```

#---
resource_group_name: pirates
##  Azure AD user.
ad_username: XXXXXXXXXXXXXXXXXXX
### Azure AD password
ad_password: XXXXXXXXXXXXXXXXXXX
#resource_group_name: oscp
#### Azure Subscription ID
subscriptionID: "XXXXXXXXXXXXXXXXXXX"
## user to login to the jump host. this user will only be created on the jumphost
adminUsername: ivan
## user pwd for jump host
## Password for the jump host
adminPassword: XXx_please_change_me_xXX
##### Public key for jump host. With the Docker installation this will be replaced dynamically
sshkey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCdC20wMbD9vmCPDD6VP6u3eYHCznqKOm+aPZi3EgUZIM7r91X7MFzuVS5U6gHXnOa4m7yh26zceh68T6FqIKby1WAGTShLFDCU6czEe0Pa5yMAV6Q4dQ34HyioTIu4HmXi4504ZxneLNJP2AHc+eJkV0ANcXIHSqoaleVyWt7HLNltFNO349GZMj01TSchBYzqZpYqSGIDsTIXwF6+/NosMLfmg6WF0J4M7A34Gn/YTXD8r2oWeSs3O+MdTMH2Zdt4j9Q8MPCgic6xDPiONpCvEdt5pkzrwaK9ZJEV4wZsV7CSy+5a+poOl/a/5F+Mj3qwqwqwFc2IRJiDkScuV07qWthKH


# see https://azure.microsoft.com/en-us/documentation/articles/cloud-services-sizes-specs/
### Size for the master
master_vmSize: Standard_DS3_v2
#master_vmSize: Standard_D2_v2
#master_vmSize: Standard_D1_v2

### Size for the nodes
node_vmSize: Standard_DS3_v2
#node_vmSize: Standard_D2_v2
#node_vmSize: Standard_D1_v2

#### Region to deploy in
region: northeurope

## docker info
docker_storage_device: /dev/sdc
create_vgname: docker_vg
filesystem: 'xfs'
create_lvsize: '80%FREE'
#create_lvsize: '2g'

#### subscription information
rh_subcription_user: XXXXXXXXXXX
rh_subcription_pass: XXXXXXXXXXX
openshift_pool_id: XXXXXXXXXXX

########### list of node  ###########
### Warning, you currently cannot create more infra nodes ####
### this will change in the future
### You can add as many nodes as you want
#####################################
jumphost:
  jumphost1:
    name: jumphost1
    tags:
      region: northeurope
      zone: jumphost
      stage: jumphost

masters:
  master1:
    name: master1
    tags:
      region: northeurope
      zone: infra
      stage: none
#  master2:
#    name: master2
#    tags:
#      region: northeurope
#      zone: infra
#      stage: none
#  master3:
#    name: master3
#    tags:
#      region: northeurope
#      zone: infra
#      stage: none

infranodes:
  infranode1:
    name: infranode1
    tags:
      region: northeurope
      zone: infra
      stage: dev
      type: core
      infratype: registry
      mbaas_id: mbaas1
  infranode2:
    name: infranode2
    tags:
      region: northeurope
      zone: infra
      stage: dev
      type: core
      mbaas_id: mbaas2
  infranode3:
    name: infranode3
    tags:
      region: northeurope
      zone: infra
      stage: dev
      type: core
      mbaas_id: mbaas3
nodes:
  node1:
    name: node1
    tags:
      region: northeurope
      zone: frontend
      stage: dev

```

## Setup

### Clone git repo
```
git clone https://github.com/tahonen/ansible-azure-docker.git
```
### Build Docker container
```
cd ansible-azure-docker
docker build -t ocpazure:latest .
```
Above build command will create an container with name ocpazure

## Installation
Open envs.txt to your favorite editor and replace sample values with correct ones.

Installation will start right after you execute docker run command described below. If you just need to start container and check what it contains add "/bin/bash" at the end of the command. Also if you need to make modifications to number of VMs installed or other tuning, just start the container not the installation. When you are done with your changes just execute /ansible-azure/install.sh.



If you start installation directly you have to mount a local directory to container so that installer can export SSH key to you. Below example will export key to directory /tmp and the name of the file by default azurekey
- The installation outputs a newly created KEY  to /tmp/azurekey.$resource_group_name


To Perform a installation successfully the following is required
  - A volume to export the generated key (this will allow you to ssh into your VMS )
  - A volume that contains a file called "all". The all file is where the azure config resides

in the below example. the folder /Users/imckinle/Projects/openshift/azure-ansible/ansible-azure/group_vars contains the all directory

```
# start installation
docker run  -v /tmp:/ansible-azure/export  -v  /Users/imckinle/Projects/openshift/azure-ansible/ansible-azure/group_vars:/ansible-azure/group_vars -it ocpazure
# start container
docker run -it -v /tmp:/ansible-azure/export  -v  /Users/imckinle/Projects/openshift/azure-ansible/ansible-azure/group_vars:/ansible-azure/group_vars  ocpazure "/bin/bash"
```


## Post install stuff

You need newly create SSH key to access jumphost. This key is exeport to given host directory or you can read it from .ssh directory if you started installation manually. If you do not manage to get hold of the key you can change SSH key to jumphost vie Azure portal (https://portal.azure.com). Key is changed from VM settings via Set password.
   - ssh -i /tmp/azurekey.$groupname

## TODO
* Define number of app and infra nodes thru envs.
* Export installation logs
