BUILD_DIR := build
DATE      := $(shell date +%Y-%m-%d)
NAME      := Brandon-Summers
PDF       := $(BUILD_DIR)/$(NAME)-$(DATE).pdf

.PHONY: all build clean

all: build

build: $(PDF) $(BUILD_DIR)/resume.json

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(PDF): resume.typ utils.typ resume.json | $(BUILD_DIR)
	typst compile --format pdf resume.typ $(PDF)

$(BUILD_DIR)/resume.json: resume.json | $(BUILD_DIR)
	cp resume.json $(BUILD_DIR)/resume.json

clean:
	rm -rf $(BUILD_DIR)
