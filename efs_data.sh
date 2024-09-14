#! /bin/bash

ap-get upadte -y
sudo apt install nfs-common -y && \
sudo systemctl status nfs-utils && \
sudo mkdir efs-file && \
sudo mount -t efs -o tls ${file_system-id} efs-file

