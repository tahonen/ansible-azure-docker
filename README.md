# Deploying Openshift Enterprise to Azure with container
Simple project to help installing HA setup of Openshift Enterprise to Azure. Installer will use https://github.com/ivanthelad/ansible-azure project to do actually installation.

Installation is done with Docker container and environmental variables that are passed to docker run command. This project is just a wrapper to actual OSE installation so check more info about the installation from above link.

## What you need to for the installation
* Azure AD account
* Enough quota for cores (by default 7 VMs )
* Red Hat account and Openshift Enterprise subscription
* Docker

## Sample config

```
# Name for Azure resource group
# OSE Master hostname is
# master-RESOURCE_GROUP_NAME.AZURE_REGION.cloudapp.azure.com
RESOURCE_GROUP_NAME=zyx
# Azure compute region
AZURE_REGION=northeurope
# Azure AD account username
AZURE_AD_USERNAME=zyz
# Azure AD account password
AZURE_AD_PASSWORD=xyz
# Azure subscription ID
AZURE_SUBS_ID=xyz
# Standard_D1_v2: 1 Core, 3.5 Gb RAM, 50 GB Disk
# Standard_D2_v2: 2 Core, 7 Gb RAM, 100 GB Disk
# Standard_D3_v2: 4 Core, 14 Gb RAM, 200 GB Disk
# see https://azure.microsoft.com/en-us/documentation/articles/cloud-services-sizes-specs/
# VM size for master node
AZURE_VM_SIZE_MASTER=Standard_D1_v2
# VM size for infra and app nodes
AZURE_VM_SIZE_NODE=Standard_D1_v2
# jumphost username
ADMIN_USERNAME=zyx
# jumphost password
ADMIN_PASSWORD=zyx
# Red Hat account username (access.redhat.com)
RH_SUBS_USER=xyz
# Red Hat account password
RH_SUBS_PASSWORD=xyz
# Subscription pool id for Openshift packages
RH_OPENSHIFT_POOL_ID=xyx
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

```
# start installation
docker run -v /tmp:/ansible-azure/export -it --env-file envs.txt ocpazure
# start container
docker run -it -v /tmp:/ansible-azure/export --env-file envs.txt ocpazure "/bin/bash"
```


## Post install stuff

You need newly create SSH key to access jumphost. This key is exeport to given host directory or you can read it from .ssh directory if you started installation manually. If you do not manage to get hold of the key you can change SSH key to jumphost vie Azure portal (https://portal.azure.com). Key is changed from VM settings via Set password.

## TODO
* Define number of app and infra nodes thru envs.
* Export installation logs
