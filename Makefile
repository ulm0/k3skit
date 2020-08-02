YALK_STATE=k3s-state
BUILD_ISO?=k3s-*
BUILD_YML?=k3s.yml
METADATA_JSON?=metadata.json
METADATA_YML?=metadata.yml
YALK_CPUS?=2
YALK_DISK?=10G
YALK_MEM?=2048

default: build

build-all:
	@linuxkit build -format iso-efi -format kernel+initrd -format kernel+squashfs $(BUILD_YML)

build:
	@linuxkit build -format kernel+squashfs $(BUILD_YML)

run-iso: json
	@sudo linuxkit -v run hyperkit -networking=vmnet -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_JSON) -iso -uefi $(BUILD_ISO)

run-initrd: json
	@sudo linuxkit -v run hyperkit -networking=vmnet -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_JSON) -kernel k3s

run: json
	@sudo linuxkit -v run hyperkit -networking=vmnet -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_JSON) -squashfs k3s

json:
	@cat $(METADATA_YML)|gojsontoyaml -yamltojson > $(METADATA_JSON)

cilium:
	@./utils/cilium

clean:
	@sudo rm -rf $(BUILD_ISO) $(METADATA_JSON) $(YALK_STATE)

linuxkit-build-docker:
	@docker build -t ulm0/linuxkit:v0.8 -f linuxkit/Dockerfile linuxkit/

linuxkit-build-push:
	@docker push ulm0/linuxkit:v0.8
