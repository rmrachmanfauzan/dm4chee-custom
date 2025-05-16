# Name of the final custom Docker image
IMAGE_NAME=my-dcm4chee-arc

# Maven Docker image to use
MAVEN_IMAGE=maven:3.9-eclipse-temurin-17

# Directory containing dcm4chee-arc-lang
LANG_DIR=../dcm4chee-arc-lang

# Path to the EAR build artifact
EAR_FILE=./dcm4chee-arc-ear/target/dcm4chee-arc-ear-5.33.1.ear

# Path to the persistent Maven repository
MAVEN_REPO=../maven-persist-build

.PHONY: all build build-lang docker-build clean up down resume

# Run everything: build arc-lang + build arc-light + build docker image
all: build-lang build docker-build

# Build the arc-lang project and install it into local Maven repo
build-lang:
	docker run --rm -it \
	  -v "$(CURDIR)/$(LANG_DIR)":/usr/src/lang \
	  -v "$(CURDIR)/$(MAVEN_REPO)":/root/.m2 \
	  -w /usr/src/lang \
	  $(MAVEN_IMAGE) \
	  mvn install -DskipTests

# Build the arc-light project
build:
	docker run --rm -it \
	  -v "$(CURDIR)":/usr/src/mymaven \
	  -v "$(CURDIR)/$(MAVEN_REPO)":/root/.m2 \
	  -w /usr/src/mymaven \
	  $(MAVEN_IMAGE) \
	  mvn clean install -DskipTests

# Resume build from last failed module
resume:
	docker run --rm -it \
	  -v "$(CURDIR)":/usr/src/mymaven \
	  -v "$(CURDIR)/$(MAVEN_REPO)":/root/.m2 \
	  -w /usr/src/mymaven \
	  $(MAVEN_IMAGE) \
	  mvn clean install -rf :dcm4chee-arc-ui2 -DskipTests

rebuild-ui:
	docker run --rm -it \
	  -v "$(CURDIR)":/usr/src/mymaven \
	  -v "$(CURDIR)/$(MAVEN_REPO)":/root/.m2 \
	  -w /usr/src/mymaven \
	  $(MAVEN_IMAGE) \
	  mvn install -pl dcm4chee-arc-ui2 -am -DskipTests

rebuild-ear:
	docker run --rm -it \
	  -v "$(CURDIR)":/usr/src/mymaven \
	  -v "$(CURDIR)/$(MAVEN_REPO)":/root/.m2 \
	  -w /usr/src/mymaven \
	  $(MAVEN_IMAGE) \
	  mvn clean install -pl dcm4chee-arc-ear -am -DskipTests

rebuild-assembly:
	docker run --rm -it \
	  -v "$(CURDIR)":/usr/src/mymaven \
	  -v "$(CURDIR)/$(MAVEN_REPO)":/root/.m2 \
	  -w /usr/src/mymaven \
	  $(MAVEN_IMAGE) \
	  mvn clean install -pl dcm4chee-arc-assembly -am -DskipTests

# Build the custom Docker image from Dockerfile
docker-build:
	docker build -t $(IMAGE_NAME) .

full-rebuild: rebuild-ui rebuild-ear docker-build
# Optional: bring up Docker Compose
up:
	docker compose up -d

# Optional: shut down Docker Compose
down:
	docker compose down

# Clean build artifacts
clean:
	rm -rf dcm4chee-arc-*/target
