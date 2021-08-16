#!/bin/bash
#
# This is a thin wrapper that maps userspace tools (executables)
# to a container where they can be run.

# /etc/kvc/bin is set in github.com/tigera/kmods-via-containers
/etc/kvc/bin/kmods-via-containers wrapper wireguard-kmod $(uname -r) $(basename $0) $@
