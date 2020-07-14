IMAGE_REPO    := norepo
IMAGE_NAME 		:= mayadata-perf
# IMAGE_TAG     := $(shell git describe --always --dirty) # commit id
IMAGE_TAG     := $(shell git rev-parse --abbrev-ref HEAD) # branch name
IMAGE_URL     := $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: build
build:
	docker build -t $(IMAGE_URL) .

.PHONY: build_unless_image_exists
build_unless_image_exists:
	docker inspect --type=image $(IMAGE_URL) 1>/dev/null || \
	docker build -t $(IMAGE_URL) .





.PHONY: interactive
interactive: build_unless_image_exists
	IMAGE_URL=$(IMAGE_URL) bash docker_run.sh



.PHONY: create_cluster
create_cluster: build_unless_image_exists
	IMAGE_URL=$(IMAGE_URL) bash docker_run.sh '-e /script/create_cluster.sh'

.PHONY: delete_cluster
delete_cluster: build_unless_image_exists
	IMAGE_URL=$(IMAGE_URL) bash docker_run.sh '-e /script/delete_cluster.sh'


.PHONY: test_performance
test_performance: build_unless_image_exists
	IMAGE_URL=$(IMAGE_URL) bash docker_run.sh '-e /script/test_performance.sh'
