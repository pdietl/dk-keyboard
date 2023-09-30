CLOUD_INIT_FILE := cloud-init.yaml
INSTANCE_NAME := pete-personal-ump
LAUNCH_ARGS := \
	--name $(INSTANCE_NAME) \
	--cpus $(shell echo $$(($$(nproc) * 2 / 3))) \
	--disk 200G \
	--memory 16G \
	--cloud-init $(CLOUD_INIT_FILE) \
	--verbose

inst-exists = $(filter true, \
    $(shell \
        multipass list --format json | jq \
            '.list | any(.name == "$(strip $1)")' \
        ) \
    )

.PHONY: all create
all create:
	$(if $(call inst-exists, $(INSTANCE_NAME)), \
		$(info The instance '$(INSTANCE_NAME)' already exists.) \
		$(info If you want to replace it, then delete and purge it first with `make delete-and-purge`.), \
		multipass launch $(LAUNCH_ARGS) \
		)

.PHONY: delete-and-purge
delete-and-purge:
	$(if $(call inst-exists, $(INSTANCE_NAME)), \
		multipass delete --purge $(INSTANCE_NAME),)

.PHONY: shell
shell:
	multipass shell $(INSTANCE_NAME)
