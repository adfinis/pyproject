.PHONY: clean-image clean-docker clean-containers root-shell shell image

SCMD := $(shell \
	if ! id -n -G | grep -q docker; then \
		echo sudo; \
	fi \
)

NCPU := $(shell \
	getconf _NPROCESSORS_ONLN 2>/dev/null || \
	getconf NPROCESSORS_ONLN 2>/dev/null || echo 1 \
)

DEVNULL := $(shell rm -rf .images)

export NCPU

clean-image: | .images clean-containers ## Remove the working docker image
	if [ -e .images/$(IMAGE_NAME) ]; then \
		$(SCMD) docker rmi -f $(IMAGE_NAME); \
	fi

clean-docker:  ## Remove all docker containers and dangling images
	$(SCMD) docker rm -v \
		$$($(SCMD) docker ps -a -q 2>/dev/null) 2>/dev/null; \
		true
	$(SCMD) docker rmi \
		$$($(SCMD) docker images -f "dangling=true" -q 2>/dev/null) 2>/dev/null; \
		true
	$(SCMD) docker volume rm \
		$$($(SCMD) docker volume ls -f "dangling=true" -q 2>/dev/null) 2>/dev/null; \
		true

clean-containers:  ## Remove old docker containers
	$(SCMD) docker rm -v \
		$$($(SCMD) docker ps -f "status=exited" -q 2>/dev/null) 2>/dev/null; \
		true

root-shell: | image  ## Open a root-shell in container
	$(SCMD) docker run -e "NCPU=$(NCPU)" -e "TERM=$(TERM)" -it $(IMAGE_NAME) /bin/bash; true

shell: | image  ## Open a shell in a container
	$(SCMD) docker run --rm -e "NCPU=$(NCPU)" -e "DISPLAY=$(DISPLAY)" \
		-e "XAUTHORITY=$(XAUTHORITY)" -e "TERM=$(TERM)" \
		-u $(shell id -u) -h "$(shell hostname)-$(IMAGE_NAME)" \
		-v "$(PWD)":/host -v /tmp/.X11-unix:/tmp/.X11-unix \
		-v "$(HOME)/.Xauthority:$(HOME)/.Xauthority" \
		-it $(IMAGE_NAME) /bin/bash; true

docker-run: | image  ## Run default command in docker
	$(SCMD) docker run --rm -e "NCPU=$(NCPU)" -u $(shell id -u) -v "$(PWD)":/host \
		-t $(IMAGE_NAME) /bin/bash -c "cd /host && $(DEFAULT_CMD)"

image: | .images .images/$(IMAGE_NAME)  ## Build the image

.images:
	$(SCMD) docker images --no-trunc | \
		sed  --posix 's/^\([[:alnum:]_/]*\).*/\1/g' | \
		grep -v -E 'REPOSITORY|^$$' | \
		xargs -I DIR mkdir -p .images/DIR

.images/$(IMAGE_NAME): | .images
	echo export HUID=\"$(shell id -u)\" > $(DOCKER_DIR)/hid.sh
	echo export HNAME=\"$(shell id -n -u)\" >> $(DOCKER_DIR)/hid.sh
	echo 'if command -v useradd >/dev/null 2>&1; then' >> $(DOCKER_DIR)/hid.sh
	echo '    useradd -u "$$HUID" "$$HNAME" 2> /dev/null' >> $(DOCKER_DIR)/hid.sh
	echo 'else' >> $(DOCKER_DIR)/hid.sh
	echo '    adduser -u "$$HUID" "$$HNAME" 2> /dev/null' >> $(DOCKER_DIR)/hid.sh
	echo 'fi' >> $(DOCKER_DIR)/hid.sh
	chmod u+x $(DOCKER_DIR)/hid.sh
	$(SCMD) docker build -t $(IMAGE_NAME) $(DOCKER_DIR)
