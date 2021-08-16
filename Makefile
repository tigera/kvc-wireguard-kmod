ifndef FAKEROOT
FAKEROOT=/tmp/tigera-wireguard-kvc/
endif

install:
	install -v -m 644 wireguard-kmod-lib.sh $(FAKEROOT)/etc/kvc/lib/kvc/
	install -v -m 644 wireguard-kmod.conf $(FAKEROOT)/etc/kvc/
	install -v -m 755 wireguard-kmod-wrapper.sh $(FAKEROOT)/etc/kvc/lib/kvc/
