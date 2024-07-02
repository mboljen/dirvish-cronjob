NAME=dirvish-cronjob
VERSION=0.0.1

DIRS=sbin share
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
	pandoc -s -M "title=$(shell echo $(NAME) | tr a-z A-Z)($(MAN_SECTION))" \
	          -M "date=$(shell date "+%B %Y")" \
	          -f markdown -t man $< | gzip -9 > $@

sign: $(SIG)

$(SIG): $(PKG)
	gpg --sign --detach-sign --armor $(PKG)

clean:
	$(RM) $(MAN) $(PKG) $(SIG)

veryclean: clean
	$(RM) -r -d $(MAN_DIR)

test:
	$(info Target `$@` not implemented yet)

tag:
	git tag v$(VERSION)
	git push --tags

release: $(PKG) $(SIG) tag

install:
	for dir in $(INSTALL_DIRS); do mkdir -p $(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(PREFIX)/$$file; done
	mkdir -p $(DOC_DIR)
	cp -r $(DOC_FILES) $(DOC_DIR)/
ifneq ($(wildcard /etc/dirvish/master.conf),)
	mv -f /etc/dirvish/master.conf /etc/dirvish/master.conf.bak
endif
	cp -u -t /etc/dirvish etc/dirvish/master.conf
	cp -u -t /etc/cron.d etc/cron.d/dirvish-volatile
	cp -u -t /etc/cron.daily etc/cron.daily/dirvish-cronjob
	cp -u -t /etc/logrotate.d etc/logrotate.d/dirvish-cronjob
	cp -u -t /etc/logrotate.d etc/logrotate.d/dirvish-volatile

uninstall:
	for file in $(INSTALL_FILES); do $(RM) -f $(PREFIX)/$$file; done
	$(RM) -r $(DOC_DIR)
	$(RM) /etc/cron.d/dirvish-volatile
	$(RM) /etc/cron.daily/dirvish-cronjob
	$(RM) /etc/logrotate.d/dirvish-cronjob
	$(RM) /etc/logrotate.d/dirvish-volatile
	$(RM) /etc/dirvish/master.conf
ifneq ($(wildcard /etc/dirvish/master.conf.bak),)
	mv -f /etc/dirvish/master.conf.bak /etc/dirvish/master.conf
endif

purge: uninstall
	$(RM) -r /var/log/$(NAME)

.PHONY: build sign man clean veryclean test tag release install uninstall all
