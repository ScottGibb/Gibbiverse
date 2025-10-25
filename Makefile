# Makefile at your project root

PROJECT_DIR := $(CURDIR)
# Paths
RAW_DIR := raw-content
CONTENT_DIR := content
LINK_FIXER := link-fixer
LINKS_FILE := $(RAW_DIR)/links.yaml
TOPICS_FILE := $(RAW_DIR)/topics.txt

# Default target when you just run `make`
.DEFAULT_GOAL := serve

# Step 1: Copy and fix content
preprocess:
	@echo "==> Syncing $(RAW_DIR) → $(CONTENT_DIR)"
	rsync -av --delete $(RAW_DIR)/ $(CONTENT_DIR)/

	@echo "==> Running link fixer"
	# run in one shell so `cd` applies to the uv command; also pass absolute paths so the script can find files
	cd $(LINK_FIXER) && \
	uv run main.py --path "$(PROJECT_DIR)/$(CONTENT_DIR)" --links "$(PROJECT_DIR)/$(LINKS_FILE)" --topics "$(PROJECT_DIR)/$(TOPICS_FILE)"

# Step 2: Run Hugo dev server (depends on preprocess)
serve: preprocess
	@echo "==> Starting Hugo server"
	hugo server

# Step 3: Watch for raw-content changes and rerun
watch:
	@echo "==> Watching $(RAW_DIR) for changes..."
	find $(RAW_DIR) -type f | entr -r make serve