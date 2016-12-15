FROM centos:latest
MAINTAINER Tero Ahonen (tahonen@redhat.com)
RUN rpm -iUvh http://www.nic.funet.fi/pub/mirrors/fedora.redhat.com/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm && yum -y update && yum -y install git ansible python-pip gcc python-devel libffi-devel openssl-devel libxml2-devel libxslt1-devel libjpeg8-devel zlib1g-devel && yum -y clean all
RUN pip install --upgrade pip && pip install msrest --upgrade && pip install msrestazure --upgrade && pip install azure==2.0.0rc5
RUN git clone https://github.com/ivanthelad/ansible-azure
COPY install.sh /ansible-azure/install.sh
RUN chmod +x /ansible-azure/install.sh && mkdir /ansible-azure/export
VOLUME /ansible-azure/group_vars
WORKDIR ansible-azure
CMD ./install.sh
