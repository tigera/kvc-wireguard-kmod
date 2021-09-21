ifndef FAKEROOT
FAKEROOT=/tmp/tigera-wireguard-kvc/
endif

install:
	install -v -m 755 -d $(FAKEROOT)/root/etc/
	install -v -m 755 -d $(FAKEROOT)/root/etc/kvc/lib/kvc/
	install -v -m 644 wireguard-kmod-lib.sh $(FAKEROOT)/root/etc/kvc/lib/kvc/
	install -v -m 644 wireguard-kmod.conf $(FAKEROOT)/root/etc/kvc/
	install -v -m 755 wireguard-kmod-wrapper.sh $(FAKEROOT)/root/etc/kvc/lib/kvc/
	install -v -m 644 Dockerfile.rhel $(FAKEROOT)/root/etc/
ignition:
	@butane --pretty -d $(FAKEROOT) < config.bu
