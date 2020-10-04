---
layout: post
title: Create a Red Hat UBI container for Fedora Toolbox
category: [all, linux]
comments: true
description: Create a Red Hat UBI container for Fedora Toolbox
tags: [ubi, ubi8, toolbox, fedora, silverblue]
---

## Fedora Toolbox
Fedora [Toolbox](https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/) is a fantastic tool which enables you to do work in an environment without touching your base system. You can compare it a bit with Python's virtualenv, but instead that it's specific for Python, you can use it for every development language or workload. 

It uses a container which is specifically crafted to be used with Toolbox and by default this is a Fedora container which matches the Fedora version you are running on. Toolbox comes preinstalled on Fedora Silverblue, which I use for several months now, but can als be installed on Fedora workstation and should work on other Linux distributions.

## Redhat Universal Base Images
> Red Hat Universal Base Images (UBI) are OCI-compliant container base operating system images with complementary runtime languages and packages that are freely redistributable. Like previous base images, they are built from portions of Red Hat Enterprise Linux. UBI images can be obtained from the Red Hat container catalog, and be built and deployed anywhere.

If you are developing for/on RHEL systems, UBI images are a great way to run your code and still be sure that it is fully compatible with a 'regular' RHEL system. And if you want to deliver your tool in a container in a Red Hat oriented environment, the UBI images are a very good 'base' to build further on.

## Combine UBI with Fedora Toolbox
In my daily work, I often need a RHEL system to test stuff on, would it not be fantastic if I could do a `toolbox create --container ubi8 --image registry.access.redhat.com/ubi8/ubi:latest`. Sadly this command results in a non-working environment because the UBI image misses some packages. Therefor I created a small shell script which creates a new UBI container which is compatible with Fedora Toolbox


```lang=shell
#!/bin/bash

NAME=$1
VERSION=${2:-'latest'}

if [ -z "${NAME}" ]; then
  echo "Usage: $0 <container-name>"
  echo " "
  echo "Example: $0 ubi:8.2-mosibi"
  exit 0
fi

CONTAINER=$(buildah from  registry.access.redhat.com/ubi8/ubi:${VERSION})
buildah run "${CONTAINER}" dnf -y install sudo less vim python3
buildah config --label com.github.{CONTAINER}s.toolbox="true" "${CONTAINER}"
buildah config --label com.github.debarshiray.toolbox="true" "${CONTAINER}"

TEMPFILE=$(mktemp)
echo 'alias __vte_prompt_command=/bin/true' > "${TEMPFILE}"
buildah copy "${CONTAINER}" "${TEMPFILE}" '/etc/profile.d/vte.sh'
buildah run "${CONTAINER}" chmod 755 /etc/profile.d/vte.sh
rm "${TEMPFILE}"

buildah commit "${CONTAINER}" "${NAME}"

echo "Container ${NAME} is created"
echo "With the following you can make changes to container ${NAME}"
echo "buildah run ${CONTAINER} <command>"
echo "buildah commit ${CONTAINER} ${NAME}"

```

Place this for example in a file `toolbox-ubi.sh` and execute it with `./toolbox-ubi.sh ubi:8.2-$(id -un)`. After this create a new toolbox container based on the newly create container with `toolbox create --container ubi8 --image ubi:8.2-$(id -un)`. From now on you can enter this container with `toolbox enter -c ubi8`.

It is also possible to execute commands in the UBI container without entering it, which can be very usable in a CI/CD tool.

```lang=shell
$ toolbox run -c ubi8 cat /etc/os-release
NAME="Red Hat Enterprise Linux"
VERSION="8.2 (Ootpa)"
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="8.2"
PLATFORM_ID="platform:el8"
PRETTY_NAME="Red Hat Enterprise Linux 8.2 (Ootpa)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:8.2:GA"
HOME_URL="https://www.redhat.com/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"

REDHAT_BUGZILLA_PRODUCT="Red Hat Enterprise Linux 8"
REDHAT_BUGZILLA_PRODUCT_VERSION=8.2
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="8.2"
```

**Podman version before 2.1.0 had a [bug](https://github.com/containers/podman/pull/7541) which resulted in a non-working environment due to missing /etc/group entries, so use Podman version 2.1.0 or newer.**

Have fun!
