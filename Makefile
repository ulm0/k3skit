BUILD_YML?=k3s.yml
BUILD_ISO?=k3s-efi.iso

build:
	@linuxkit build -format iso-efi $(BUILD_YML)

run:
	@linuxkit run hyperkit -disk size=4096M -iso -uefi $(BUILD_ISO)
