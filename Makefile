YALK_STATE=k3s-state
BUILD_ISO?=k3s-*
BUILD_YML?=k3s.yml
METADATA_JSON?=metadata.json
METADATA_YML?=metadata.yml
METADATA_W_JSON?=metadata-w.json
METADATA_W_YML?=metadata-w.yml
YALK_CPUS?=2
YALK_DISK?=20G
YALK_MEM?=4096

default: build

build-all:
	@linuxkit build -format iso-efi -format kernel+initrd -format kernel+squashfs $(BUILD_YML)

build:
	@linuxkit build -format kernel+squashfs $(BUILD_YML)

run-iso: json
	@sudo linuxkit -v run qemu -arch="x86_64" -networking="bridge,br0" -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_JSON) -iso -uefi $(BUILD_ISO)

run-initrd: json
	@sudo linuxkit -v run qemu -arch="x86_64" -networking="bridge,br0" -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_JSON) -kernel k3s

run: clean-state json
	@sudo linuxkit -v run qemu -arch="x86_64" -networking="bridge,br0" -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_JSON) -squashfs k3s

run-worker: clean-state-w json-w
	@sudo linuxkit -v run qemu -arch="x86_64" -networking="bridge,br0" -cpus=$(YALK_CPUS) -mem=$(YALK_MEM) -disk size=$(YALK_DISK) -data-file=$(METADATA_W_JSON) -state=./k3s-worker -kernel k3s

json:
	@cat $(METADATA_YML)|gojsontoyaml -yamltojson > $(METADATA_JSON)

json-w:
	@cat $(METADATA_W_YML)|gojsontoyaml -yamltojson > $(METADATA_W_JSON)

cilium:
	@./utils/cilium

clean:
	@rm -f $(BUILD_ISO) $(METADATA_JSON)

linuxkit-build-docker:
	@docker build -t ulm0/linuxkit:v0.8 -f linuxkit/Dockerfile linuxkit/

linuxkit-push-docker:
	@docker push ulm0/linuxkit:v0.8

clean-state:
	@sudo rm -rf $(YALK_STATE)

clean-state-w:
	@sudo rm -rf ./k3s-worker

clean-all: clean clean-state
