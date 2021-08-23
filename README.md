# kvc-wireguard-kmod

This is a [kmods-via-containers](https://github.com/kmods-via-containers/kmods-via-containers) implementation for WireGuard using [atomic-wireguard](https://github.com/jdoss/atomic-wireguard.git) example.

The intended utility of this repository is for fulfilling some of the Openshift encrypt cluster traffic steps here: https://docs.projectcalico.org/security/encrypt-cluster-pod-traffic#install-wireguard


## Quick config variables guide


|[wireguard-kmod.conf](wireguard-kmod.conf)|comment|
|---|---|
|WIREGUARD_KERNEL_VERSION| Run `uname -r` on your cluster to fill out this field |
|WIREGUARD_VERSION| Please obtain the `tar.xz` file of the latest [wireguard-linux-compat version here](https://git.zx2c4.com/wireguard-linux-compat/) without the 'v' prefix |
|WIREGUARD_SHA256| SHA256 of the above `wireguard-linux-compat-(version).tar.xz` file |
|KERNEL_CORE_RPM| Link to kernel-core rpm for the selected kernel version. See Note 1 below |
|KERNEL_DEVEL_RPM| Link to kernel-core rpm for the selected kernel version. Note 1 below |
|KERNEL_MODULES_RPM| Link to kernel-core rpm for the selected kernel version. See Note 1 below |


#### Note 1: You can find links to  official packages in your [RedHat Subscription](https://access.redhat.com/downloads/content/package-browser). Links must be accessible by your cluster.


## Compatibility table

WireGuard snapshots vs kernel version compatibility for [atomic-wireguard](https://github.com/projectcalico/) kvc build system

This may aid in populating the [wireguard-kmod.conf](wireguard-kmod.conf). However, please always use the [latest wireguard snapshot](https://git.zx2c4.com/wireguard-linux-compat/) vs the latest kernel version (by running `uname -r` on your cluster).

| WIREGUARD_VERSION | WIREGUARD_SHA256 | WIREGUARD_KERNEL_VERSION |
|---|---|---|
| 1.0.20210606 | 60850724988809d7ff9065848b830859b2f57c1366b0ce37af2d37138f540f49 | 4.18.0-240.22.1.el8_3.x86_64 |
| 1.0.20210219 | 99d35296b8d847a0d4db97a4dda96b464311a6354e75fe0bef6e7c4578690f00 | 4.18.0-240.15.1.el8_3.x86_64 |
| 1.0.20200611 | 9b0478c3b1f3a7b488916e632e2fcbb1383bb1a2ef294489858ce2ba1da3246d | 4.18.0-193.60.2.el8_2.x86_64 |
| 1.0.20200520 | 16e7ae4bef734b243428eea07f3b3c3d4721880c3ea8eb8f98628fd6ae5b77c3 | 4.18.0-193.28.1.el8_2.x86_64 |



## EXPERIMENTAL: Trying out latest wireguard-linux-compat (master)

If your OCP workers' kernel is newer than any of the above tested options, please try the latest [wireguard backport](https://git.zx2c4.com/wireguard-linux-compat) master version.

    # download latest wireguard code first
    wget https://git.zx2c4.com/wireguard-linux-compat/snapshot/wireguard-linux-compat-master.tar.xz

    # the first part of the output of the following command goes into wireguard-kmod.conf at variable WIREGUARD_SHA256
    sha256sum wireguard-linux-compat-master.tar.xz


| WIREGUARD_VERSION | WIREGUARD_SHA256 | WIREGUARD_KERNEL_VERSION |
|---|---|---|
| master | see commands above | `uname -r` output of your OCP workers |


To troubleshoot and debug to see if this has produced any build errors during the kmods-via-containers service build phase, this can be done via `oc debug`:

1. `$ oc debug node/<node-name>`
1. `# chroot /host`
1. `# bash`
1. `$ journalctl --unit=kmods-via-containers@wireguard-kmod.service -n 1000 --no-pager`

Submit issues here: https://github.com/tigera/kvc-wireguard-kmod/issues/new 


## TROUBLESHOOTING

1. `oc apply -f mc-wg.yaml` but nothing is happening!

    check machine-config-operator output for details: `oc logs -n openshift-machine-config-operator -l k8s-app=machine-config-controller --since=3h -f`

1. `butane` ignition config output is too new for my cluster
    
    consider manually editing the resulting `mc-wg.yaml` file's `config.ignition.version` field value from `3.2.0` to `2.2.0`. Or, alternatively, [consult the Butane Config spec documentation](https://coreos.github.io/butane/specs/) for more information on editing [config.bu](config.bu).
