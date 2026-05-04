BUILD_DIR := build
DATE      := $(shell date +%Y-%m-%d)
NAME      := Brandon-Summers
PDF       := $(BUILD_DIR)/$(NAME)-$(DATE).pdf
PDF_GENERIC := $(BUILD_DIR)/resume.pdf

.PHONY: all compile clean

all: compile

compile: $(PDF) $(PDF_GENERIC) $(BUILD_DIR)/resume.json

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(PDF): resume.typ utils.typ resume.json | $(BUILD_DIR)
	typst compile --format pdf resume.typ $(PDF)

$(PDF_GENERIC): resume.typ utils.typ resume.json | $(BUILD_DIR)
	typst compile --format pdf resume.typ $(PDF_GENERIC)

$(BUILD_DIR)/resume.json: resume.json | $(BUILD_DIR)
	cp resume.json $(BUILD_DIR)/resume.json

clean:
	rm -rf $(BUILD_DIR)
