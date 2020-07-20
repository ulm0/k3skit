WHICH_BIN=$(shell which linuxkit)
LKT_BIN=/usr/local/bin/linuxkit
YALK_STATE=k3s-efi-state
BUILD_ISO?=k3s-efi.iso
BUILD_YML?=k3s.yml
METADATA_JSON?=metadata.json
METADATA_YML?=metadata.yml
YALK_CPUS?=2
YALK_DISK?=10G
YALK_MEM?=2048
YALK_NET?=vmnet
ifeq ($(YALK_NET), vmnet)
YALK_RUN=yalk-sudo-run
YALK_CLEAN=yalk-sudo-clean
else
YALK_RUN=yalk-run
YALK_CLEAN=yalk-clean
endif
ifneq ($(WHICH_BIN),$(LKT_BIN))
LKT_BIN=./linuxkit
endif

build:
	@$(LKT_BIN) build -format iso-efi $(BUILD_YML)

yalk-sudo-run: json
	@sudo linuxkit -v run hyperkit -networking=vmnet -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_JSON) -iso -uefi $(BUILD_ISO)

yalk-run: json
	@linuxkit -v run hyperkit -networking=$(YALK_NET) -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_JSON) -iso -uefi $(BUILD_ISO)

run: $(YALK_RUN)

json:
	@cat $(METADATA_YML)|gojsontoyaml -yamltojson > $(METADATA_JSON)

cilium:
	@./utils/cilium

clean: $(YALK_CLEAN)

yalk-sudo-clean:
	@sudo rm -rf $(BUILD_ISO) $(METADATA_JSON) $(YALK_STATE)

yalk-clean:
	@rm -rf $(BUILD_ISO) $(METADATA_JSON) $(YALK_STATE)
