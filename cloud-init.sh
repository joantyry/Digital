#!/bin/bash
#cloud-config
# Cloud-init configuration file to set up the VM

#(3) Format and mount the additional disk

  mkfs.xfs /dev/sdb
  mkdir -p /var/lib/docker
  mount /dev/sdb /var/lib/docker
  echo '/dev/sdb /var/lib/docker xfs defaults 0 0' >> /etc/fstab

#(4) Create deployuser with passwordless sudo
  useradd deployuser
  echo 'deployuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

#(5) Create guest accounts
  for i in {01..10}; do useradd guest$i; done
