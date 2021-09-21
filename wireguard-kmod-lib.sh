#!/bin/bash

# The MIT License

# Copyright (c) 2019 Dusty Mabe

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -eu

# This library is to be sourced in as part of the kmods-via-containers
# framework. There are some environment variables that are used in this
# file that are expected to be defined by the framework already:
# - KVC_CONTAINER_RUNTIME
#   - The container runtime to use (example: podman|docker)
# - KVC_SOFTWARE_NAME
#   - The name of this module software bundle
# - KVC_KVER
#   - The kernel version we are targeting

# There are other environment variables that come from the config file
# delivered alongside this library. The expected variables are:
# - KMOD_CONTAINER_BUILD_CONTEXT
#   - A string representing the location of the build context
# - KMOD_CONTAINER_BUILD_FILE
#   - The name of the file in the context with the build definition
#     (i.e. Dockerfile)
# - KMOD_SOFTWARE_VERSION
#   - The version of the software bundle
# - KMOD_NAMES
#   - A space separated list kernel module names that are part of the
#     module software bundle and are to be checked/loaded/unloaded
source "/etc/kvc/${KVC_SOFTWARE_NAME}.conf"

# The name of the container image to consider. It will be a unique
# combination of the module software name/version and the targeted
# kernel version.
IMAGE="${KVC_SOFTWARE_NAME}-${KMOD_SOFTWARE_VERSION}:${WIREGUARD_KERNEL_VERSION}"

build_kmod_container() {
    echo "Building ${IMAGE} kernel module container..."
    kvc_c_build -t ${IMAGE}                                     \
        --file ${KMOD_CONTAINER_BUILD_FILE}                     \
        --label="name=${KVC_SOFTWARE_NAME}"                     \
        --build-arg WIREGUARD_VERSION=${WIREGUARD_VERSION}      \
        --build-arg WIREGUARD_SHA256=${WIREGUARD_SHA256}        \
        --build-arg WIREGUARD_KERNEL_VERSION=${WIREGUARD_KERNEL_VERSION} \
        --volume /host/var/wireguard-rpms:/tmp:ro \
        ${KMOD_CONTAINER_BUILD_CONTEXT}

    # get rid of any dangling containers if they exist
    echo "Checking for old kernel module images that need to be recycled"
    rmi1=$(kvc_c_images -q -f label="name=${KVC_SOFTWARE_NAME}" -f dangling=true)
    # keep around any non-dangling images for only the most recent 3 kernels
    rmi2=$(kvc_c_images -q -f label="name=${KVC_SOFTWARE_NAME}" -f dangling=false | tail -n +4)
    if [ ! -z "${rmi1}" -o ! -z "${rmi2}" ]; then
        echo "Cleaning up old kernel module container builds"
        kvc_c_rmi -f $rmi1 $rmi2
    fi
}

is_kmod_loaded() {
    module=${1//-/_} # replace any dashes with underscore
    if lsmod | grep "${module}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

build_kmods() {
    build_kmod_container
}

load_kmods() {
    echo "Loading kernel modules using the kernel module container..."
    for module in ${KMOD_EXTRA_NAMES} ${KMOD_NAMES}; do
        if is_kmod_loaded ${module}; then
            echo "Kernel module ${module} already loaded"
        else
            module=${module//-/_} # replace any dashes with underscore
            kvc_c_run --privileged $IMAGE modprobe -S ${WIREGUARD_KERNEL_VERSION} ${module}
        fi
    done
}

unload_kmods() {
    echo "Unloading kernel modules..."
    for module in ${KMOD_NAMES} ${KMOD_EXTRA_NAMES}; do
        if is_kmod_loaded ${module}; then
            module=${module//-/_} # replace any dashes with underscore
            rmmod "${module}"
        else
            echo "Kernel module ${module} already unloaded"
        fi
    done
}

wrapper() {
    echo "Running userspace wrapper using the kernel module container..."
    kvc_c_run --privileged $IMAGE $@
}
