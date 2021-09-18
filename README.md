# kvc-wireguard-kmod

This is a [kmods-via-containers](https://github.com/kmods-via-containers/kmods-via-containers) implementation for WireGuard using [atomic-wireguard](https://github.com/jdoss/atomic-wireguard.git) example.

The intended utility of this repository is for fulfilling some of the Openshift encrypt cluster traffic steps here: https://docs.projectcalico.org/security/encrypt-cluster-pod-traffic#install-wireguard


# Quickstart

1. Edit [wireguard-kmod.conf](wireguard-kmod.conf)
1. `export FAKEROOT=$(mktemp -d)`
1. `make -C kmods-via-container install FAKEROOT=$FAKEROOT`
1. `make -C kvc-wireguard-kmod install FAKEROOT=$FAKEROOT`
1. `make -sC kvc-wireguard-kmod FAKEROOT=$FAKEROOT ignition > mc-wg.yaml` 


## Quick config variables guide


|[wireguard-kmod.conf](wireguard-kmod.conf)|comment|
|---|---|
|WIREGUARD_KERNEL_VERSION| Run `uname -r` on your cluster to fill out this field |
|WIREGUARD_VERSION| Please obtain the `tar.xz` file of the latest [wireguard-linux-compat version here](https://git.zx2c4.com/wireguard-linux-compat/) without the 'v' prefix |
|WIREGUARD_SHA256| SHA256 of the above `wireguard-linux-compat-(version).tar.xz` file |

## Compatibility table

WireGuard snapshots vs kernel version compatibility for [atomic-wireguard](https://github.com/projectcalico/) kvc build system

This may aid in populating the [wireguard-kmod.conf](wireguard-kmod.conf). However, please always use the [latest wireguard snapshot](https://git.zx2c4.com/wireguard-linux-compat/) vs the latest kernel version (by running `uname -r` on your cluster).

| WIREGUARD_VERSION | WIREGUARD_SHA256 | WIREGUARD_KERNEL_VERSION | actual uname -r |
|---|---|---|---|
| 1.0.20210606 | 3f5d990006e6eabfd692d925ec314fff2c5ee7dcdb869a6510d579acfdd84ec0 | 4.18.0-305.el8.x86_64 | 4.18.0-305.19.1.el8_4.x86_64 |
| 1.0.20210606 | 3f5d990006e6eabfd692d925ec314fff2c5ee7dcdb869a6510d579acfdd84ec0 | 4.18.0-240.el8.x86_64 | 4.18.0-240.22.1.el8_3.x86_64 |
| 1.0.20210219 | 99d35296b8d847a0d4db97a4dda96b464311a6354e75fe0bef6e7c4578690f00 | 4.18.0-240.el8.x86_64 | 4.18.0-240.15.1.el8_3.x86_64 |
| 1.0.20200611 | 9b0478c3b1f3a7b488916e632e2fcbb1383bb1a2ef294489858ce2ba1da3246d | 4.18.0-193.el8.x86_64 | 4.18.0-193.60.2.el8_2.x86_64 |
| 1.0.20200520 | 16e7ae4bef734b243428eea07f3b3c3d4721880c3ea8eb8f98628fd6ae5b77c3 | 4.18.0-193.el8.x86_64 | 4.18.0-193.28.1.el8_2.x86_64 |


To troubleshoot and debug to see if this has produced any build errors during the kmods-via-containers service build phase, this can be done via `oc debug`:



Submit issues here: https://github.com/tigera/kvc-wireguard-kmod/issues/new 


## TROUBLESHOOTING

1. `oc apply -f mc-wg.yaml` but nothing is happening!

    check machine-config-operator output for details: `oc logs -n openshift-machine-config-operator -l k8s-app=machine-config-controller --since=3h -f`

1. machine-config-operator was accepted / not in a degraded state but wireguard isn't working!

    check the systemd output for the userspace service that runs kmod in one of the worker nodes
    ```bash
    $ oc debug node/<node-name> # must be a worker node, for now
    # chroot /host
    # bash
    $ journalctl --unit=kmods-via-containers@wireguard-kmod.service -n 1000 --no-pager
    ```

1. `butane` ignition config output is too new for my cluster
    
    consider manually editing the resulting `mc-wg.yaml` file's `config.ignition.version` field value from `3.2.0` to `2.2.0`. Or, alternatively, [consult the Butane Config spec documentation](https://coreos.github.io/butane/specs/) for more information on editing [config.bu](config.bu).
