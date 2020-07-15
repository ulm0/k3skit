BUILD_YML?=k3s.yml
BUILD_ISO?=k3s-efi.iso

build:
	@linuxkit build -format iso-efi $(BUILD_YML)

run:
	@sudo linuxkit run hyperkit -networking=vmnet -disk size=10240M -iso -uefi $(BUILD_ISO)
