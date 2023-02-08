#!/bin/bash -eux

apt -y update
apt -y install git python3-pip
apt -y upgrade
pip3 --no-cache-dir install ansible
