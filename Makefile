NAME=dirvish-cronjob
VERSION=0.0.1

DIRS=etc sbin share
INSTALL_DIRS=`find $(DIRS) -type d 2>/dev/null`
INSTALL_FILES=`find $(DIRS) -type f 2>/dev/null`
DOC_FILES=$(wildcard *.md *.txt)

PKG_DIR=pkg
PKG_NAME=$(NAME)-$(VERSION)
PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
SIG=$(PKG_DIR)/$(PKG_NAME).asc

PREFIX?=/usr/local
DOC_DIR=$(PREFIX)/share/doc/$(PKG_NAME)

MAN_SECTION ?= 1
MAN_DIR = share/man/man$(MAN_SECTION)
MAN = $(MAN_DIR)/$(NAME).$(MAN_SECTION).gz

build: $(MAN) $(PKG)

all: $(MAN) $(PKG) $(SIG)

pkg:
	mkdir -p $(PKG_DIR)

$(PKG): pkg
	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD

man:
	mkdir -p $(MAN_DIR)

$(MAN): README.md man
	pandoc -s -M "title=$(NAME)($(MAN_SECTION))" -M "date=$(shell date "+%a %F %R %Z")" -t man $< | gzip -9 > $(MAN)

sign: $(SIG)

$(SIG): $(PKG)
	gpg --sign --detach-sign --armor $(PKG)

clean:
	$(RM) $(MAN) $(PKG) $(SIG)

test:

tag:
	git tag v$(VERSION)
	git push --tags

release: $(PKG) $(SIG) tag

install:
	for dir in $(INSTALL_DIRS); do mkdir -p $(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(PREFIX)/$$file; done
	mkdir -p $(DOC_DIR)
	cp -r $(DOC_FILES) $(DOC_DIR)/
ifneq ($(PREFIX),)
	[ -f /etc/dirvish/master.conf ] && mv /etc/dirvish/master.conf /etc/dirvish/master.conf.bak
	ln -sf $(PREFIX)/etc/cron.daily/dirvish-cronjob /etc/cron.daily/dirvish-cronjob
	ln -sf $(PREFIX)/etc/cron.d/dirvish-volatile /etc/cron.d/dirvish-volatile
	ln -sf $(PREFIX)/etc/dirvish/master.conf /etc/dirvish/master.conf
	ln -sf $(PREFIX)/etc/logrotate.d/dirvish-cronjob /etc/logrotate.d
	ln -sf $(PREFIX)/etc/logrotate.d/dirvish-volatile /etc/logrotate.d
endif

uninstall:
	for file in $(INSTALL_FILES); do $(RM) -f $(PREFIX)/$$file; done
	$(RM) -r $(DOC_DIR)
ifneq ($(PREFIX),)
	$(RM) /etc/logrotate.d/dirvish-cronjob
	$(RM) /etc/logrotate.d/dirvish-volatile
	$(RM) /etc/cron.d/dirvish-volatile
	$(RM) /etc/cron.daily/dirvish-cronjob
	$(RM) /etc/dirvish/master.conf
	[ -f /etc/dirvish/master.conf.bak ] && mv /etc/dirvish/master.conf.bak /etc/dirvish/master.conf
endif

.PHONY: build sign man clean test tag release install uninstall all
