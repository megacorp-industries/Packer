#!/bin/bash

if [ ! -f ./virtio-win.iso ]
then
    echo "virtio iso not present in current directory, downloading now..."
    wget --show-progress https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
else
    echo "virtio iso already exists, skipping..."
fi

packer build win22core.pkr.hcl
