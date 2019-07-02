MAKE       := make -w
PWD        := $(shell pwd)

ALWAYS_DOWNLOAD     := n
ALWAYS_PULL         := n

OUTPUT_DIR          := $(PWD)/output
BUILD_DIR           := $(OUTPUT_DIR)/build
TARGET_DIR          := $(OUTPUT_DIR)/target

DOWNLOAD_DIR        := $(HOME)/Downloads

PJPROJECT_DIR       := $(BUILD_DIR)/pjproject-2.9

define download
	@echo "download $2"; \
	if [ ! -d  $(DOWNLOAD_DIR) ];then mkdir $(DOWNLOAD_DIR);fi; \
	if [ -f $(DOWNLOAD_DIR)/$(2).tmp ];then rm $(DOWNLOAD_DIR)/$(2).tmp;fi; \
	if [ ! -f $(DOWNLOAD_DIR)/$(2) ] && ([ ! -d $(1) ] || [ "$(ALWAYS_DOWNLOAD)" = "y" ]);then \
		if [ -x /usr/bin/wget ];then wget -O $(DOWNLOAD_DIR)/$(2).tmp $(3); \
		elif [ -x /usr/bin/curl ]; then curl -Lo $(DOWNLOAD_DIR)/$(2).tmp $(3); \
		else echo "please install wget or curl";fi;fi; \
	if [ -f $(DOWNLOAD_DIR)/$(2).tmp ];then mv $(DOWNLOAD_DIR)/$(2).tmp $(DOWNLOAD_DIR)/$(2);fi; \
	if [ -f $(DOWNLOAD_DIR)/$(2) ] && [ ! -d $(1) ];then \
		if [ ! -d $(BUILD_DIR) ];then mkdir -p $(BUILD_DIR);fi; \
		echo "unpack "$(2); \
		if [ ! -z $(filter %.tar.gz, $(2)) ];then tar xzf $(DOWNLOAD_DIR)/$(2) -C $(BUILD_DIR);fi; \
		if [ ! -z $(filter %.tar.bz2, $(2)) ];then tar xjf $(DOWNLOAD_DIR)/$(2) -C $(BUILD_DIR);fi; \
		if [ ! -z $(filter %.tar.xz, $(2)) ];then tar xJf $(DOWNLOAD_DIR)/$(2) -C $(BUILD_DIR);fi; \
		if [ ! -z $(filter %.tar, $(2)) ];then tar xf $(DOWNLOAD_DIR)/$(2) -C $(BUILD_DIR);fi; \
		if [ ! -z $(filter %.zip, $(2)) ];then unzip $(DOWNLOAD_DIR)/$(2) -d $(BUILD_DIR);fi; \
	fi;
endef

define git_clone
    @echo "clone $2"; \
	if [ -d $2 ] && [ "$(ALWAYS_PULL)" = "y" ];then git -C $2 pull;fi; \
    if [ ! -d $2 ];then git clone $1 $2;fi
endef

define git_clone_branch
    @echo "clone $2:$3"; \
	if [ -d $2 ] && [ "$(ALWAYS_PULL)" = "y" ];then git -C $2 pull origin $3;fi; \
    if [ ! -d $2 ];then git clone $1 $2 && cd $2 && git checkout -b $3 $3;fi
endef

PHONY := all
all:arm64 armv7 armv7s x64 x86

libs:
	if [ ! -d $(TARGET_DIR)/include ];then mkdir -p $(TARGET_DIR)/include;fi
	$(MAKE) -C $(PJPROJECT_DIR) install DESTDIR=$(OUTPUT_DIR)/tmp
	cp -rf $(OUTPUT_DIR)/tmp/usr/local/include/* $(TARGET_DIR)/include/
	rm -rf $(OUTPUT_DIR)/tmp
	$(PWD)/libs.sh

PHONY := arm64
arm64:
	echo '#define PJ_CONFIG_IPHONE 1\n#include <pj/config_site_sample.h>' > $(PJPROJECT_DIR)/pjlib/include/pj/config_site.h
	cd $(PJPROJECT_DIR) && CFLAGS="-O2 -Wno-unused-label -fembed-bitcode" ARCH='-arch arm64' ./configure-iphone
	$(MAKE) -C $(PJPROJECT_DIR) dep
	$(MAKE) -C $(PJPROJECT_DIR) clean
	$(MAKE) -C $(PJPROJECT_DIR)

PHONY := armv7
armv7:
	echo '#define PJ_CONFIG_IPHONE 1\n#include <pj/config_site_sample.h>' > $(PJPROJECT_DIR)/pjlib/include/pj/config_site.h
	cd $(PJPROJECT_DIR) && CFLAGS="-O2 -Wno-unused-label -fembed-bitcode" ARCH='-arch armv7' ./configure-iphone
	$(MAKE) -C $(PJPROJECT_DIR) dep
	$(MAKE) -C $(PJPROJECT_DIR) clean
	$(MAKE) -C $(PJPROJECT_DIR)

PHONY := armv7s
armv7s:
	echo '#define PJ_CONFIG_IPHONE 1\n#include <pj/config_site_sample.h>' > $(PJPROJECT_DIR)/pjlib/include/pj/config_site.h
	cd $(PJPROJECT_DIR) && CFLAGS="-O2 -Wno-unused-label -fembed-bitcode" ARCH='-arch armv7s' ./configure-iphone
	$(MAKE) -C $(PJPROJECT_DIR) dep
	$(MAKE) -C $(PJPROJECT_DIR) clean
	$(MAKE) -C $(PJPROJECT_DIR)

PHONY := x64
x64:
	echo '#define PJ_CONFIG_IPHONE 1\n#include <pj/config_site_sample.h>' > $(PJPROJECT_DIR)/pjlib/include/pj/config_site.h
	cd $(PJPROJECT_DIR) && DEVPATH="/Applications/XCode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer" ARCH="-arch x86_64" CFLAGS="-O2 -m64 -mios-simulator-version-min=7.0 -fembed-bitcode" LDFLAGS="-O2 -m64 -mios-simulator-version-min=7.0" ./configure-iphone
	$(MAKE) -C $(PJPROJECT_DIR) dep
	$(MAKE) -C $(PJPROJECT_DIR) clean
	$(MAKE) -C $(PJPROJECT_DIR)


PHONY := x86
x86:
	echo '#define PJ_CONFIG_IPHONE 1\n#include <pj/config_site_sample.h>' > $(PJPROJECT_DIR)/pjlib/include/pj/config_site.h
	cd $(PJPROJECT_DIR) && DEVPATH="/Applications/XCode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer" ARCH="-arch i386" CFLAGS="-O2 -m64 -mios-simulator-version-min=7.0 -fembed-bitcode" LDFLAGS="-O2 -m64 -mios-simulator-version-min=7.0" ./configure-iphone
	$(MAKE) -C $(PJPROJECT_DIR) dep
	$(MAKE) -C $(PJPROJECT_DIR) clean
	$(MAKE) -C $(PJPROJECT_DIR)

PHONY += download
download:
	$(call download,$(PJPROJECT_DIR),pjproject-2.9.tar.bz2,"https://www.pjsip.org/release/2.9/pjproject-2.9.tar.bz2")
	# $(call git_clone,$(REPO_GROUP)/rtl8723bu-wifi.git,$(RTL8723BU_WIFI_DIR))

PHONY += clean
clean:
	rm -rf $(TARGET_DIR)

.PHONY: $(PHONY)

