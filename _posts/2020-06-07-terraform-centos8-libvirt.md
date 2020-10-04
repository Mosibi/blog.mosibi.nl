---
layout: post
title: Create a CentOS 8 virtual machine using Terraform
categories: [all, linux]
comments: true
description: Create a CentOS8 virtual machine using Terraform
tags: terraform, centos8
---

Often I need a virtual machine just to run stuff on for all kind of 'lab' work and most of the times, I choose CentOS as the operating system. Until now I used a
script I wrote many years ago which uses the QEMU backing file construction to quickly create a new host based on that backing file, so for each OS 
flavor I have a backing file. But in the current times where everything smells 'cloud' I would like to also create my hosts in a more 'cloud' way of working where
I create and remove the nodes and every around it without having to know every bit about the underlying hardware, and that is where Terraform comes in.

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions. A big plus for Terraform is, if you
have your installation working as it should be, and you change to a different (cloud) solution, the changes you have to make to your Terraform recipes are most of the times very minimal. I am going to use the libvirt provider, which
enables me to create virtual machines on my laptop, just like it was a Amazon or Google Cloud.
 
## Install Terraform
Installing Terraform is very simple, [download](https://www.terraform.io/downloads.html) the CLI binary for your platform and place in your $PATH, for example in your personal bin directory ~/bin/. For example

```lang=shell
wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip
unzip -x terraform_0.12.26_linux_amd64.zip 
mv terraform ~/bin/terraform
mv terraform ~/bin/terraform_0.12.26_linux_amd64 
rm ~/bin/terraform
ln -s ~/bin/terraform_0.12.26_linux_amd64 ~/bin/terraform
```

## Install the libvirt provider for Terraform
The libvirt provider is not a built-in provider, so we have to install this one seperatly. Localy installed Terraform providers are placed in `~/.terraform.d/plugins`, if that directory is not present yet, you have to create it
```lang=shell
mkdir -p ~/.terraform.d/plugins
```

Download the latest version of the plugin and place it in the plugins directory. The example below assumes you are working on a Red Hat family system, else visit [https://github.com/dmacvicar/terraform-provider-libvirt/releases](https://github.com/dmacvicar/terraform-provider-libvirt/releases) to download the plugin for another platform.

```lang=shell
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64.tar.gz
tar xvzf terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64.tar.gz -C ~/.terraform.d/plugins/
```

## Install your first virtual machine
First clone my git repository and see what is in there. You will find there a file `centos8.tf` which is the Terraform recipe and a cloud init file `cloud_init.cfg`. In `cloud_init.cfg` I set the root password, create a group and an user and install some packages. Change this file to your own wishes, you probably do not want a user richard with my public SSH key on your system :). If you look in the file `centos8.tf`, you will notice that the cloud init configuration is rendered as an ISO file and that ISO file is attached to the system so that the cloud-init service can pick it up and execute what is needed.

```lang=shell
git clone https://github.com/Mosibi/centos8-terraform.git
```

Each first time you create a new Terraform project, you must initialize the project, do that with the following commands

```lang=shell
cd centos8-terraform
terraform init
terraform plan
```

And finally, install that CentOS 8 virtual machine!
```lang=shell
terraform apply
```

A few variables are defined the top of the file `centos8.tf` which enable you the change the settings of the virtual machine. Those settings can be changed in the file, but also from the command line. Just like this


```lang=shell
terraform apply -auto-approve --var 'vm_name=test-vm' --var 'memory=2048' --var 'cpu=2'
```

![Install demo](install.gif)

## Cleanup
```lang=shell
terraform destroy -auto-approve   
```
