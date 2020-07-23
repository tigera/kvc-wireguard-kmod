ifndef DESTDIR
DESTDIR=/usr/
endif
ifndef CONFDIR
CONFDIR=/etc
endif

install:
	install -v -m 644 wireguard-kmod-lib.sh $(DESTDIR)/lib/kvc/
	install -v -m 644 wireguard-kmod.conf $(CONFDIR)/kvc/
	install -v -m 755 wireguard-kmod-wrapper.sh $(DESTDIR)/lib/kvc/
	ln -sf ../lib/kvc/wireguard-kmod-wrapper.sh $(DESTDIR)/bin/wg
